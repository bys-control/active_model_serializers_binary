module DataTypes
  class Type
    attr_accessor :value, :bit_length, :type

    def initialize(type=nil, bit_length=nil, sign=nil, count=1, length=1)
      @type = type
      @bit_length = bit_length
      @sign = sign
      @count = count
      @length = length
      @default_value = 0
    end

    def to_s
      @value.to_s
    end

    # Return size of object in bytes
    def size
      (@bit_length*@length*@count)/8.0
    end

    def check_value(value)
      if value.nil?
        value=0
      else
        value=(value.is_a? Array) ? value : [value]
      end

      value.map!{|v| v.nil? ? @default_value : v}
      value.map! do |v|
          case @default_value.class.name
            when "Float"
              v.to_f
            when "String"
              v.to_s[0...@length]
            else
              v.to_i
          end
      end

      value=value[0...@count]
      value.fill(@default_value, value.length...@count)
    end

    def value=(value)
      value = check_value(value)

      # Recorta los valores según el bit_length
      value.map! do |v|
        (@sign == :signed)?[-2**(@bit_length-1),[v.to_i,2**(@bit_length-1)-1].min].max :
            ((@sign == :unsigned)? [0,[v.to_i,2**(@bit_length)-1].min].max : v )
      end
      @value=value
    end
  end

  class Int8 < Type
    def initialize(count=1, length=1)
      super :int8, 8, :signed, count
      self.value = @default_value
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      @value
    end

    def load(value)
      self.value = value if !value.nil?
      @value
    end
  end

  class Int16 < Type
    def initialize(count=1, length=1)
      super :int16, 16, :signed, count
      self.value = @default_value
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      @value.pack('v*').unpack('C*')
    end

    def load(value)
      self.value = value.pack('C*').unpack('v*') if !value.nil?
      @value
    end
  end

  class Int32 < Type
    def initialize(count=1, length=1)
      super :int32, 32, :signed, count
      self.value = @default_value
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      @value.pack('V*').unpack('C*')
    end

    def load(value)
      self.value = value.pack('C*').unpack('V*') if !value.nil?
      @value
    end
  end

  class UInt16 < Type
    def initialize(count=1, length=1)
      super :uint16, 16, :unsigned, count
      self.value = @default_value
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      @value.pack('v*').unpack('C*')
    end

    def load(value)
      self.value = value.pack('C*').unpack('v*') if !value.nil?
      @value
    end
  end

  class UInt32 < Type
    def initialize(count=1, length=1)
      super :uint32, 32, :unsigned, count
      self.value = @default_value
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      @value.pack('l*').unpack('C*')
    end

    def load(value)
      self.value = value.pack('C*').unpack('l*') if !value.nil?
      @value
    end
  end

  class UInt8 < Type
    def initialize(count=1, length=1)
      super :uint8, 8, :unsigned, count
      self.value = @default_value
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      @value
    end

    def load(value)
      self.value = value if !value.nil?
      @value
    end
  end

  class BitField < Type
    def initialize(count=1, length=8)
      length = 8 if length > 8
      super :bitfield, length, :unsigned, count
      @value = 0
    end

    def dump(value=nil)
      @value = value if !value.nil?
      data = @value.pack('C*').unpack('b*').first.chars.each_slice(8).map(&:join).map{|n| n.slice(0,bit_length)}
      [data.join].pack('b*').unpack('C*')
    end

    def load(value)
      #binding.pry
      @value = value.pack('C*').unpack('b*').first.chars.slice(0,@bit_length*@count).each_slice(bit_length).map(&:join).map{|n| [n].pack('b*').unpack('C*').first}
      @value
    end
  end

  class Char < Type
    def initialize(count=1, length=1)
      super :char, 8, nil, count, length
      @default_value = "\x0"
      self.value = @default_value
    end

    #@todo: corregir lo de abajo:
    def self.serialize(value)
      var = Char.new
      var.value = value
      var.serialize
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      @value.map{|v| v.ljust(@length, @default_value).slice(0,@length).unpack('C*')}
    end

    def load(value)
      self.value = value.pack('C*').unpack("Z#{@length}") if !value.nil?
      @value
    end
  end

  class Bool < Type
    def initialize(count=1, length=1)
      super :bool, 1, :unsigned, count
      self.value = 0
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      [@value.join].pack('b*').unpack('C*')
    end

    def load(value)
      self.value = value.pack('C*').unpack('b*').first.slice(0,size*8).split('').map(&:to_i) if !value.nil?
      @value
    end
  end

  class Float32 < Type
    def initialize(count=1, length=1)
      super :float32, 32, nil, count
      @default_value = 0.0
      self.value = @default_value
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      @value.pack('e*').unpack('C*')
    end

    def load(value)
      self.value = value.pack('C*').unpack('e*') if !value.nil?
      @value
    end
  end
end