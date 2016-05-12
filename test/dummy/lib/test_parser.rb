require 'active_model_serializers_binary/active_model_serializers_binary'
require 'colorize'

class String
  def map
    size.times.with_object('') {|i,s| s << yield(self[i])}
  end
end

class Producto
	include ActiveModel::Serializers::Binary

	attr_accessor :start_address, :id, :silo, :nombre, :total_acumulado, :bits1, :bits2, :float, :total_acumulado_1, :variable

    def attributes
    	instance_values
    end

	# def metodo
	# 	self.instance_variable_get("@variable")
	# end

	# def metodo= (value)
	# 	self.instance_variable_set("@variable", value)
	# end

	# Formato atributo, Coder, Count, Length
	serialize_options :id, Int16
	serialize_options :silo, Int16
	serialize_options :nombre, Char,1, 20
	serialize_options :total_acumulado, Int32
	serialize_options :bits1, Bool, 1
	serialize_options :bits2, Bool, 1
	serialize_options :total_acumulado_1, Int32
	serialize_options :float, Float32
	serialize_options :variable, Char, 1, 20
end


orig = Producto.new
orig.start_address = 0
orig.id = 1
orig.silo = 0
orig.nombre = "MAIZ"
orig.total_acumulado = 50
orig.bits1 = 1
orig.bits2 = 1
orig.total_acumulado_1 = 20
orig.float= 1.2345678
orig.variable = '012345678901234567890123456789'

puts 'Datos originales...'
puts orig.inspect.green

puts 'serializando...'
serial = orig.to_bytes

puts serial.inspect.yellow

puts 'deserializando...'
deser = Producto.new.from_bytes serial
puts deser.inspect.green