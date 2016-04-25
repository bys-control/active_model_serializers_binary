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
	 	@variable = '012345678901234567890123456789'
	end
end

orig = Producto.new

puts 'Datos originales...'
puts orig.inspect.green

puts 'serializando...'
serial = orig.to_bytes do |b|
	puts '@variable original: ', b.variable
	b.variable = b.variable.map {|c| (c.ord+10).chr}
	puts '@variable modificada: ', b.variable
end

puts serial.inspect.yellow

puts 'deserializando...'
deser = Producto.new.from_bytes serial do |b|
	puts 'datos leidos: ', b.variable
	b.variable = b.variable.map {|c| (c.ord-10).chr}
	puts 'datos modificados: ', b.variable
end
puts deser.inspect.green