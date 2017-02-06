require 'active_model_serializers_binary/active_model_serializers_binary'
require 'colorize'

class String
  def map
    size.times.with_object('') {|i,s| s << yield(self[i])}
  end
end

orig = Producto.new
orig.uid = 1
orig.silo = 0
orig.nombre = "MAIZ"
orig.total_acumulado = 50
orig.bits1 = 1
orig.bits2 = 1
orig.bits3 = 1
orig.bits4 = nil
orig.bits5 = nil
orig.bits6 = nil
orig.bits7 = nil
orig.bits8 = nil
orig.bits9 = nil
orig.bits10 = nil
orig.bits11 = nil
orig.bits12 = nil
orig.bits13 = nil
orig.bits14 = nil
orig.bits15 = nil
orig.bits16 = nil
orig.ffloat= 1.2345678
orig.variable = '012345678901234567890123456789'
orig.test = (1..10).to_a

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

must_be_equal = (serial <=> deser.to_bytes) === 0
puts "Test OK".green if must_be_equal
puts "Test fail".red unless must_be_equal