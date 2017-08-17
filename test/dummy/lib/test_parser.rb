require 'active_model_serializers_binary/active_model_serializers_binary'
require 'colorize'

class String
  def map
    size.times.with_object('') {|i,s| s << yield(self[i])}
  end
end

orig = Producto.new
orig.nombre = "AAAAAAAAAAAAAAAAAAAA"
orig.tipo = Tipo.new({name:"BBBBBBBBBBBBBBBBBBBB", producto_id: 0x55AA})

puts 'Datos originales...'
puts orig.inspect.green

puts 'serializando...'
serial = orig.to_bytes 

puts serial.inspect.yellow

puts 'deserializando...'
deser = Producto.new.from_bytes serial
puts deser.inspect.green

must_be_equal = (serial <=> deser.to_bytes) === 0
puts "Test OK".green if must_be_equal
puts "Test fail".red unless must_be_equal