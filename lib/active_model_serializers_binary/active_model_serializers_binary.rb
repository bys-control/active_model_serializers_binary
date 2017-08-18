require 'active_model'
require 'active_support/core_ext/object' # Helpers para los objetos (instance_values, etc.)
require_relative 'data_types'

module ActiveModel
  module Serializers
    # == Active Model Binary serializer
    module Binary
      extend ActiveSupport::Concern
      include ActiveModel::Model
      include ActiveModel::Serialization
      include DataTypes

      included do
        extend ActiveModel::Naming

        class_attribute :attr_config
        class_attribute :serialize_options_global
        self.attr_config = []
        self.serialize_options_global = {}

        def attributes
          keys = self.attr_config.select{ |attr| attr[:virtual]==true }.map{ |attr| attr[:name] }
          values = keys.map{ |attr| self.instance_variable_get("@#{attr}") }
          (super rescue {}).merge(Hash[keys.zip values])
        end

        def initialize( *args )
          initialize_serializer
          super rescue super()
        end

        def initialize_serializer
          self.class.add_virtual_attributes self
        end

        after_initialize :initialize_serializer rescue nil

        endianess :little
        align     false
      end

      module ClassMethods
        def add_virtual_attributes( instance )
          self.attr_config.each{ |attr| add_virtual_attribute(instance, attr) }
        end

        def add_virtual_attribute( instance, attr )
          if attr[:virtual] == true
            true
          else
            attr_name = attr[:name].to_s
            if !instance.respond_to? attr_name
              attr[:virtual] = true
              attr_accessor attr_name
              true
            else
              false
            end
          end
        end

        def serialize_attribute_options( attr_name, options, &block )
          self.attr_config.push(options.merge({:name => attr_name.to_s, block: block }))
          if options[:virtual]==true
            attr_accessor attr_name
          end
        end       

        def int8( attr_name, options = {}, &block )
          options = self.serialize_options_global.merge(options)
          serialize_attribute_options attr_name, options.merge({coder: DataTypes::Int8}), &block
        end

        def int16( attr_name, options = {}, &block )
          options = self.serialize_options_global.merge(options)
          serialize_attribute_options attr_name, options.merge({coder: DataTypes::Int16}), &block
        end

        def int16le( attr_name, options = {}, &block )
          int16( attr_name, options.merge({endianess: :little}), &block )
        end

        def int16be( attr_name, options = {}, &block )
          int16( attr_name, options.merge({endianess: :big}), &block )
        end

        def int32( attr_name, options = {}, &block )
          options = self.serialize_options_global.merge(options)
          serialize_attribute_options attr_name, options.merge({coder: DataTypes::Int32}), &block
        end

        def int32le( attr_name, options = {}, &block )
          int32( attr_name, options.merge({endianess: :little}), &block )
        end

        def int32be( attr_name, options = {}, &block )
          int32( attr_name, options.merge({endianess: :big}), &block )
        end

        def uint8( attr_name, options = {}, &block )
          options = self.serialize_options_global.merge(options)
          serialize_attribute_options attr_name, options.merge({coder: DataTypes::UInt8}), &block
        end

        def uint16( attr_name, options = {}, &block )
          options = self.serialize_options_global.merge(options)
          serialize_attribute_options attr_name, options.merge({coder: DataTypes::UInt16}), &block
        end

        def uint16le( attr_name, options = {}, &block )
          uint16( attr_name, options.merge({endianess: :little}), &block )
        end

        def uint16be( attr_name, options = {}, &block )
          uint16( attr_name, options.merge({endianess: :big}), &block )
        end

        def uint32( attr_name, options = {}, &block )
          options = self.serialize_options_global.merge(options)
          serialize_attribute_options attr_name, options.merge({coder: DataTypes::UInt32}), &block
        end

        def uint32le( attr_name, options = {}, &block )
          uint32( attr_name, options.merge({endianess: :little}), &block )
        end

        def uint32be( attr_name, options = {}, &block )
          uint32( attr_name, options.merge({endianess: :big}), &block )
        end       

        def bitfield( attr_name, options = {}, &block )
          options = self.serialize_options_global.merge(options)
          serialize_attribute_options attr_name, options.merge({coder: DataTypes::BitField, type: :bitfield}), &block
        end

        def float32( attr_name, options = {}, &block )
          options = self.serialize_options_global.merge(options)
          serialize_attribute_options attr_name, options.merge({coder: DataTypes::Float32}), &block
        end

        def float64( attr_name, options = {}, &block )
          options = self.serialize_options_global.merge(options)
          serialize_attribute_options attr_name, options.merge({coder: DataTypes::Float64}), &block
        end

        def char( attr_name, options = {}, &block )
          options = self.serialize_options_global.merge(options)
          serialize_attribute_options attr_name, options.merge({coder: DataTypes::Char}), &block
        end

        def bool( attr_name, options = {}, &block )
          options = self.serialize_options_global.merge(options)
          serialize_attribute_options attr_name, options.merge({coder: DataTypes::Bool, type: :bool}), &block
        end

        def nest( attr_name, options={}, &block )
          options = self.serialize_options_global.merge(options)
          serialize_attribute_options attr_name, options.merge({type: :nest}), &block
        end

        def endianess( type = :little )
          self.serialize_options_global.merge!({endianess: type})
        end

        def align( boundary = false )
          self.serialize_options_global.merge!({align: boundary})
        end
      end

      class Serializer #:nodoc:
        attr_accessor :start_address

        def initialize(serializable, options = nil)
          @serializable = serializable
          @options = options ? options.dup : {}
          @current_address = 0
          @start_address = 0
          @current_byte = 0
          @current_bit = 0
        end

        def current_address= (value)
          @current_address = value
          @current_byte = value.floor
          @current_bit = (value.modulo(1)*8).round
        end

        def current_address
          @current_address
        end

        def current_byte= (value)
          @current_byte = value
          @current_address = (@current_byte+@current_bit/8.0)
        end

        def current_byte
          @current_byte
        end

        def current_bit= (value)
          @current_bit = value
          @current_address = (@current_byte+@current_bit/8.0)
        end

        def current_bit
          @current_bit
        end

        def align_data( attr_options, var )
          # XXX: hay que sacar nest de acá
          if !attr_options[:type].in? [:bitfield, :bool, :nest]
            # Se posiciona al principio de un byte
            if self.current_bit != 0
              self.current_address = self.current_address.ceil
            end
            if @options[:align]==:dword
              # Si el dato es una palabra simple, alinea los datos en el siguiente byte par
              if var.bit_length > 8 and (self.current_address + self.start_address).modulo(2) != 0
                self.current_byte += 1
              end
              # Si el dato es una palabra doble, alinea los datos en la siguiente palabra par
              if var.bit_length > 16 and (self.current_address + self.start_address).modulo(4) != 0
                self.current_byte += 4-self.current_byte%4
              end
            elsif @options[:align]==:word
              # Si el dato es una palabra simple, alinea los datos en el siguiente byte par
              if var.bit_length > 8 and (self.current_address + self.start_address).modulo(2) != 0
                self.current_byte += 1
              end
            end
          end
        end

        def dump
          serializable_values = @serializable.serializable_hash(@options)
          self.start_address = @options[:start_address] || 0

          buffer = [] # Data Buffer
          tmp_buffer = [] # Aux Data Buffer

          self.current_address = self.start_address # Address in bytes

          @serializable.attr_config.each do |attr_options|
            attr_name = attr_options[:name]
            if attr_options[:type] != :nest
              var = attr_options[:coder].new(attr_options.merge(parent: @serializable))
              var.value = serializable_values[attr_name] rescue nil
            else
              var_value = serializable_values[attr_name].attributes rescue nil
              var = attr_options[:coder].new(var_value)
            end

            tmp_buffer = var.dump

            align_data(attr_options, var) if @options[:align]

            # Si los datos ocupan mas de un byte concatena los arrays
            if !attr_options[:type].in? [:bitfield, :bool] and @options[:align]
              buffer.insert(self.current_byte, tmp_buffer).flatten!
            else # En caso de ser bits
              tmp_buffer.flatten!
              tmp_bits=tmp_buffer.pack('C*').unpack('b*').first.slice(0,var.size*8)
              tmp_buffer=[tmp_bits.rjust(tmp_bits.length+self.current_bit,'0')].pack('b*').unpack('C*')

              tmp_buffer.each_with_index do |v,i|
                buffer[self.current_byte+i] = (buffer[self.current_byte+i] || 0) | v
              end
            end

            self.current_address += var.size
          end
          buffer.map!{|el| el || 0}
        end

        #deserializado
        def load (buffer=[])
          serialized_values = {}
          self.start_address = @options[:start_address] || 0

          buffer ||= [] # Buffer en bytes
          tmp_buffer = [] # Buffer temporal en bytes

          self.current_address = self.start_address # Dirección en bytes

          @serializable.attr_config.each do |attr_options|
            attr_name = attr_options[:name]

            var = attr_options[:coder].new(attr_options.merge(parent: @serializable)) #creo objeto del tipo de dato pasado

            align_data(attr_options, var) if @options[:align]

            # Si los datos ocupan mas de un byte, obtiene los bytes completos del buffer original
            if !attr_options[:type].in? [:bitfield, :bool] and @options[:align]
              result_deserialized=var.load(buffer.slice(self.current_byte, var.size))
            else # En caso de ser bits
              tmp_buffer = buffer.slice(self.current_byte, (var.size+self.current_bit/8.0).ceil)
              result_deserialized=var.load([tmp_buffer.pack('C*').unpack('b*').first.slice(self.current_bit,var.size*8)].pack('b*').unpack('C*'))
            end

            if attr_options[:type] == :nest
              serialized_values["#{attr_name}"] = result_deserialized
            else
              serialized_values["#{attr_name}"] = result_deserialized.count>1 ? result_deserialized : result_deserialized.first
            end
            self.current_address += var.size
          end

          # Asigno los datos leidos
          serialized_values.each do |k,v|
            @serializable.send("#{k}=", v)
          end
          @serializable
        end

        # Return size of object in bytes
        def size
          serializable_values = @serializable.serializable_hash(@options)
          self.start_address = @options[:start_address] || 0

          current_address = 0.0 # Dirección en bytes

          @serializable.attr_config.each do |attr_options|
            var = attr_options[:coder].new(attr_options.merge(parent: @serializable))

            align_data(attr_options, var) if @options[:align]

            self.current_address += var.size
          end
          self.current_address-self.start_address
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
        options = self.serialize_options_global.deep_merge(options)
        if block_given?
            yield self
        end
        Serializer.new(self, options).dump
      end

      alias_method :dump, :to_bytes

      def to_words(options = {}, &block)
        data = to_bytes(options, &block)
        byte_count = (data.count/2.0).ceil*2
        data.fill(0, data.count...byte_count).pack('C*').unpack('v*')
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
        options = self.serialize_options_global.deep_merge(options)
        retVal = Serializer.new(self, options).load buffer
        
        if block_given?
          yield self
        end
        retVal
      end

      alias_method :load, :from_bytes

      def from_words(buffer = [], options = {}, &block)
        data = buffer.pack('v*').unpack('C*')
        from_bytes(data, options, &block)
      end

      def size(options = {})
        options = self.serialize_options_global.deep_merge(options)
        Serializer.new(self, options).size
      end

    end
  end
end