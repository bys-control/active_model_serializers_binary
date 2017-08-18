require 'active_model_serializers_binary/active_model_serializers_binary'
require 'colorize'

class String
  def map
    size.times.with_object('') {|i,s| s << yield(self[i])}
  end
end

orig = Product.new

orig.int8 = 1;
orig.int16 = 1;
orig.int16le = 1;
orig.int16be = 1;
orig.int32 = 1;
orig.int32le = 1;
orig.int32be = 1;
orig.uint8 = 1;
orig.uint16 = 1;
orig.uint16le = 1;
orig.uint16be = 1;
orig.uint32 = 1;
orig.uint32le = 1;
orig.uint32be = 1;
orig.bitfield = 1;
orig.float32 = 1;
orig.float64 = 1;
orig.char = "A";
orig.bool = 1;
orig.type = Type.new({product_id: 1, name: "ABCDEFGHIJKLMNOPQRST"})

puts 'Datos originales...'
puts orig.inspect.green

puts 'serializando...'
serial = orig.to_bytes 

puts serial.inspect.yellow

puts 'deserializando...'
deser = Product.new.from_bytes serial
puts deser.inspect.green

must_be_equal = (serial <=> deser.to_bytes) === 0
puts "Test OK".green if must_be_equal
puts "Test fail".red unless must_be_equal