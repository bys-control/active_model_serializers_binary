require 'active_model'
require 'active_support/core_ext/object' # Helpers para los objetos (instance_values, etc.)
require_relative 'data_types'

module ActiveModel
  module Serializers
    # == Active Model Binary serializer
    module Binary
      extend ActiveSupport::Concern
      include ActiveModel::Serialization
      include DataTypes

      included do
        extend ActiveModel::Naming

        class_attribute :attr_config
        self.attr_config = {}

        def initialize
          super
          self.attr_config.each do |key, options|
            options[:parent] = self
          end
        end
      end

      module ClassMethods
        # todo: agrupar parametros en hash (rompe la compatibilidad hacia atras)
        def serialize_options(attr_name, coder, count=1, length=1, &block )
          self.attr_config.merge!(attr_name.to_s => {:coder => coder, :count => count, :length => length, :block => block, :name => attr_name})
        end

        def int8( attr_name, options = {}, &block )
          serialize_options attr_name, DataTypes::Int8, options[:count], options[:length], &block
        end

        def int16( attr_name, options = {}, &block )
          serialize_options attr_name, DataTypes::Int16, options[:count], options[:length], &block
        end

        def int32( attr_name, options = {}, &block )
          serialize_options attr_name, DataTypes::Int32, options[:count], options[:length], &block
        end

        def uint8( attr_name, options = {}, &block )
          serialize_options attr_name, DataTypes::UInt8, options[:count], options[:length], &block
        end

        def uint16( attr_name, options = {}, &block )
          serialize_options attr_name, DataTypes::UInt16, options[:count], options[:length], &block
        end

        def uint32( attr_name, options = {}, &block )
          serialize_options attr_name, DataTypes::UInt32, options[:count], options[:length], &block
        end

        def bitfield( attr_name, options = {}, &block )
          serialize_options attr_name, DataTypes::BitField, options[:count], options[:length], &block
        end

        def float32( attr_name, options = {}, &block )
          serialize_options attr_name, DataTypes::Float32, options[:count], options[:length], &block
        end

        def char( attr_name, options = {}, &block )
          serialize_options attr_name, DataTypes::Char, options[:count], options[:length], &block
        end

        def bool( attr_name, options = {}, &block )
          serialize_options attr_name, DataTypes::Bool, options[:count], options[:length], &block
        end
      end

      class Serializer #:nodoc:
        attr_reader :options

        def initialize(serializable, options = nil)
          @serializable = serializable
          @options = options ? options.dup : {}
        end

        def dump
          serializable_values = @serializable.serializable_hash(options)
          start_address = @options[:start_address] || 0

          buffer = [] # Buffer en bytes
          tmp_buffer = [] # Buffer temporal en bytes
          current_address = start_address*2 + 0.0 # Dirección en bytes

          @serializable.attr_config.each do |key, options|
            var = options[:coder].new(options)
            # Busca el valor del atributo y si no existe devuelve nil
            var.value = serializable_values[key] rescue nil

            byte = current_address.floor
            bit = (current_address.modulo(1)*8).round

            tmp_buffer = var.dump

            if @options[:align]
              if !var.type.in? [:bitfield, :bool]
                # Se posiciona al principio de un byte
                if bit != 0
                  byte += 1
                  bit = 0
                  current_address = (byte+bit/8.0)
                end
                # Si el dato es una palabra simple, alinea los datos en el siguiente byte par
                if var.bit_length > 8 and current_address.modulo(2) != 0
                  byte += 1
                  bit = 0
                end
                # Si el dato es una palabra doble, alinea los datos en la siguiente palabra par
                if var.bit_length > 16 and (current_address + start_address*2).modulo(4) != 0
                  byte += 4-byte%4
                  bit = 0
                end
              end
            end

            # Si los datos ocupan mas de un byte concatena los arrays
            if !var.type.in? [:bitfield, :bool] and @options[:align]
              buffer.insert(byte, tmp_buffer).flatten!
            else # En caso de ser bits
              tmp_buffer.flatten!
              tmp_bits=tmp_buffer.pack('C*').unpack('b*').first.slice(0,var.size*8)
              tmp_buffer=[tmp_bits.rjust(tmp_bits.length+bit,'0')].pack('b*').unpack('C*')

              tmp_buffer.each_with_index do |v,i|
                buffer[byte+i] = (buffer[byte+i] || 0) | v
              end
            end

            current_address = (byte+bit/8.0)+var.size
          end
          buffer.map!{|el| el || 0}
        end

        #deserializado
        def load (buffer=[])
          serialized_values = {}
          start_address = @options[:start_address] || 0

          buffer ||= [] # Buffer en bytes
          tmp_buffer = [] # Buffer temporal en bytes

          current_address = start_address*2 + 0.0 # Dirección en bytes

          @serializable.attr_config.each do |key, options|
            #puts "#{key} - #{options}"
            byte = current_address.floor
            bit = (current_address.modulo(1)*8).round

            var = options[:coder].new(options) #creo objeto del tipo de dato pasado

            if @options[:align]
              if !var.type.in? [:bitfield, :bool]
                # Se posiciona al principio de un byte
                if bit != 0
                  byte += 1
                  bit = 0
                  current_address = (byte+bit/8.0)
                end
                # Si el dato es una palabra simple, alinea los datos en el siguiente byte par
                if var.bit_length > 8 and current_address.modulo(2) != 0
                  byte += 1
                  bit = 0
                end
                # Si el dato es una palabra doble, alinea los datos en la siguiente palabra par
                if var.bit_length > 16 and (current_address + start_address*2).modulo(4) != 0
                  byte += 4-byte%4
                  bit = 0
                end
              end
            end

            # Si los datos ocupan mas de un byte, obtiene los bytes completos del buffer original
            if var.bit_length >= 8 and @options[:align]
              result_deserialized=var.load(buffer.slice(byte, var.size))
            else # En caso de ser bits
              tmp_buffer = buffer.slice(byte, (var.size+bit/8.0).ceil)
              result_deserialized=var.load([tmp_buffer.pack('C*').unpack('b*').first.slice(bit,var.size*8)].pack('b*').unpack('C*'))
            end
            # puts result_deserialized.inspect
            serialized_values["#{key}"] = result_deserialized.count>1 ? result_deserialized : result_deserialized.first
            current_address = (byte+bit/8.0)+var.size
          end

          # if !@serializable.instance_variable_get(:@attributes).nil?
          #   @serializable.instance_variable_get(:@attributes).merge!(serialized_values) rescue nil
          # else
            serialized_values.each do |k,v|
              if @serializable.respond_to? "#{k}="
                @serializable.send("#{k}=", v)
              else
                @serializable.instance_variable_set("@#{k}".to_sym, v)
              end
            end
          #end
          @serializable
        end

      end #close class serializer

      # Returns a binary array representing the model. Configuration can be
      # passed through +options+.
      #
      #   person = Person.find(1)
      #   person.to_bytes
      #
      #   => [98, 111, 98, 0, 0, 0, 0, 0, 0, 0, 22, 0, 1]
      #
      def to_bytes(options = {}, &block)
        default_options = {
            :align => true,
        }
        options = default_options.deep_merge(options)
        if block_given?
            yield self
        end
        Serializer.new(self, options).dump
      end

      # Sets the model +attributes+ from an Binary string. Returns +self+.
      #
      #   class Person
      #     include ActiveModel::Serializers::Binary
      #
      #     attr_accessor :name, :age, :awesome
      #
      #     def attributes=(hash)
      #       hash.each do |key, value|
      #         instance_variable_set("@#{key}", value)
      #       end
      #     end
      #
      #     def attributes
      #       instance_values
      #     end
      #
      #     char :name, count: 1, length: 10
      #     int16 :age
      #     bool :awesome
      #   end
      #
      #   bytes = [98, 111, 98, 0, 0, 0, 0, 0, 0, 0, 22, 0, 1]
      #   person = Person.new
      #   person.from_bytes(bytes) do |p|
      #     p.name.upcase!
      #   end
      #   => #<Person:0x007fec5e3b3c40 @age=22, @awesome=true, @name="bob">
      #
      # @param [Array] buffer byte array with model data to deserialize
      # @param [Hash] options deserealization options
      #
      # @return [Object] Deserialized object
      # 
      # @yield code block to execute after deserialization
      #
      def from_bytes(buffer, options = {}, &block)
        default_options = {
            :align => true
        }
        options = default_options.deep_merge(options)
        retVal = Serializer.new(self, options).load buffer
        
        if block_given?
          yield self
        end
        retVal
      end
    end
  end
end