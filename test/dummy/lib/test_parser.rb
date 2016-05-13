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

	def attributes=(hash)
		hash.each do |key, value|
			instance_variable_set("@#{key}", value)
		end
	end

	# def metodo
	# 	self.instance_variable_get("@variable")
	# end

	# def metodo= (value)
	# 	self.instance_variable_set("@variable", value)
	# end

	int16 :id
	int16 :silo
	char :nombre, count: 1, length: 20
	int32 :total_acumulado
	bool :bits1
	bool :bits2
	int32 :total_acumulado_1
	float32 :float
	char :variable, count: 1, length: 20 do |field, mode|
		binding.pry
		puts (mode.to_s + ': variable block').blue
	end
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
serial = orig.to_bytes do |b|
	puts 'to_bytes block'.blue
end

puts serial.inspect.yellow

puts 'deserializando...'
deser = Producto.new.from_bytes serial do |b|
	puts 'from_bytes block'.blue
end
puts deser.inspect.green