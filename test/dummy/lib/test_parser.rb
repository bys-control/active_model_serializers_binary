require 'active_model_serializers_binary/active_model_serializers_binary'
require 'colorize'

class Producto
	include ActiveModel::Serializers::Binary

	attr_accessor :start_address, :id, :silo, :nombre, :total_acumulado, :bits1, :bits2, :float, :total_acumulado_1

    def attributes
    	instance_values
    end

	# Formato atributo, Coder, Count, Length
	serialize_options :id, Int16
	serialize_options :silo, Int16
	serialize_options :nombre, Char,1, 20
	serialize_options :total_acumulado, Int32
	serialize_options :bits1, Bool, 1
	serialize_options :bits2, Bool, 1
	serialize_options :total_acumulado_1, Int32
	serialize_options :float, Float32

	def initialize
	 	@start_address = 0
	 	@id = 1
	 	@silo = 0
	 	@nombre = "MAIZ"
	 	@total_acumulado = 50
	 	@bits1 = 1
	 	@bits2 = 1
	 	@total_acumulado_1 = 20
	 	@float= 1.2345678
	end
end

orig = Producto.new

puts 'Datos originales...'
puts orig.inspect.green

puts 'serializando...'
serial = orig.to_bytes
puts serial.inspect.yellow

puts 'deserializando...'
deser = Producto.new.from_bytes(serial)
puts deser.inspect.green