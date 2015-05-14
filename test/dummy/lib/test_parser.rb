require 'active_model_serializers_binary/active_model_serializers_binary'
require 'colorize'

class Producto
	include ActiveModel::Serializers::Binary

	attr_accessor :start_address, :id, :silo, :nombre, :total_acumulado, :bits1, :bits2, :float, :total_acumulado_1, :variable

    def attributes
    	instance_values.merge({"metodo" => self.metodo})
    end

	def metodo
		self.instance_variable_get("@variable")
	end

	def metodo= (value)
		self.instance_variable_set("@variable", value)
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
	serialize_options :metodo, Char, 1, 20

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
	 	@variable = "12345678901234567890"
	end
end

orig = Producto.new

puts 'Datos originales...'
puts orig.inspect.green

puts 'serializando...'
serial = orig.to_bytes({:align => false})
puts serial.inspect.yellow

puts 'deserializando...'
deser = Producto.new.from_bytes(serial, {:align => false})
puts deser.inspect.green

#[1, 0, 0, 0, 77, 65, 73, 90, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 0, 0, 0, 3, 0, 0, 0, 20, 0, 0, 0, 81, 6, 158, 63, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48]
