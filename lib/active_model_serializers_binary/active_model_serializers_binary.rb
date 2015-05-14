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
      end

      module ClassMethods
        def serialize_options(attr_name, coder, count=1, length=1)
          self.attr_config.merge!(attr_name.to_s => {:coder => coder, :count => count, :length => length})
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

          @serializable.attr_config.each do |key, value|
            var = value[:coder].new(value[:count], value[:length])
            # Busca el valor del atributo y si no existe devuelve nil
            var.value = serializable_values[key] rescue nil

            byte = current_address.floor
            bit = (current_address.modulo(1)*8).round

            tmp_buffer = var.dump

            if @options[:align]
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

            # Si los datos ocupan mas de un byte concatena los arrays
            if var.bit_length >= 8 and @options[:align]
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

          @serializable.attr_config.each do |key, value|
            #puts "#{key} - #{value}"
            byte = current_address.floor
            bit = (current_address.modulo(1)*8).round

            var = value[:coder].new(value[:count], value[:length]) #creo objeto del tipo de dato pasado

            if @options[:align]
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

            # Si los datos ocupan mas de un byte, obtiene los bytes completos del buffer original
            if var.bit_length >= 8 and @options[:align]
              result_deserialized=var.load(buffer.slice(byte, var.size))
            else # En caso de ser bits
              tmp_buffer = buffer.slice(byte, var.size.ceil)
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
              if @serializable.methods.include? "#{k}=".to_sym
                @serializable.send("#{k}=".to_sym, v)
              else
                @serializable.instance_variable_set("@#{k}", v)
              end
            end
          #end

          @serializable
        end

      end #close class serializer

      # Returns XML representing the model. Configuration can be
      # passed through +options+.
      #
      # Without any +options+, the returned XML string will include all the
      # model's attributes.
      #
      #   user = User.find(1)
      #   user.to_xml
      #
      #   <?xml version="1.0" encoding="UTF-8"?>
      #   <user>
      #     <id type="integer">1</id>
      #     <name>David</name>
      #     <age type="integer">16</age>
      #     <created-at type="dateTime">2011-01-30T22:29:23Z</created-at>
      #   </user>
      #
      # The <tt>:only</tt> and <tt>:except</tt> options can be used to limit the
      # attributes included, and work similar to the +attributes+ method.
      #
      # To include the result of some method calls on the model use <tt>:methods</tt>.
      #
      # To include associations use <tt>:include</tt>.
      #
      # For further documentation, see <tt>ActiveRecord::Serialization#to_xml</tt>
      def to_bytes(options = {})
        Serializer.new(self, options).dump
      end

      # Sets the model +attributes+ from an XML string. Returns +self+.
      #
      #   class Person
      #     include ActiveModel::Serializers::Xml
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
      #   end
      #
      #   xml = { name: 'bob', age: 22, awesome:true }.to_xml
      #   person = Person.new
      #   person.from_xml(xml) # => #<Person:0x007fec5e3b3c40 @age=22, @awesome=true, @name="bob">
      #   person.name          # => "bob"
      #   person.age           # => 22
      #   person.awesome       # => true
      def from_bytes(buffer, options = {})
        Serializer.new(self, options).load buffer
      end
    end
  end
end