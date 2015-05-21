module DataTypes
  class Type
    attr_accessor :value, :bit_length

    def initialize(bit_length=nil, sign=nil, count=1, length=1)
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
        value=@value
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
      super 8, :signed, count
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
      super 16, :signed, count
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
      super 32, :signed, count
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
      super 16, :unsigned, count
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
      super 32, :unsigned, count
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
      super 8, :unsigned, count
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

  class Char < Type
    def initialize(count=1, length=1)
      super 8, nil, count, length
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
      self.value = value.pack('C*').unpack("A#{@length}") if !value.nil?
      @value
    end
  end

  class Bool < Type
    def initialize(count=1, length=1)
      super 1, :unsigned, count
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
      super 32, nil, count
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