#require 'active_support/core_ext/object'
require 'serializer_binary/serializer_binary'

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
	 	@nombre = ["MAIZ", "EXPELLER"]
	 	@total_acumulado = 50
	 	@bits1 = 1
	 	@bits2 = 1
	 	@total_acumulado_1 = 20
	 	@float= 1.2345678
	end
end

# producto = Producto.new
# producto.id.value = 1
# producto.silo.value = 0
# producto.nombre.value = ['MAIZ']
# producto.total_acumulado.value = 50
# producto.bits1.value = [1,1,0,1,0,0,1,1,1]
# producto.bits2.value = [1,1,0,1,0,0,1,1,1]
# producto.total_acumulado_1.value = 20
# producto.float.value = 1.2345678

# puts 'Datos originales...'
# puts producto.instance_variables.map{|var| producto.instance_variable_get(var)}.select{|v| defined? v.load}

# puts 'serializando...'
# ser = producto.serialize
# puts ser.inspect

# puts 'deserializando...'
# deser = producto.deserialize(ser)
# puts deser

