module DataTypes
  class Type

    attr_accessor :value, :bit_length, :type

    def initialize(type=nil, bit_length=nil, sign=nil, count=1, length=1, default_value=0)
      @default_value = default_value
      @raw_value = nil
      @bit_length = bit_length
      @type = type
      @sign = sign # :signed / :unsigned
      @count = count # Cantidad de elementos del array
      @length = length # En char y bitfield especifica la longitud del campo. Ignorado para el resto de los tipos
      @value = check_value(default_value)
    end

    def to_s
      @value.to_s
    end

    # Return size of object in bytes
    def size
      ((@bit_length*@length*@count)/8.0).ceil
    end

    def check(type, count, length, bit_length, sign, default_value, value)
      value = Array(value) # Se asegura de que sea un array
      value = value[0...count]  # Corta el array según la cantidad de elementos especificados en la declaración
      # Lo convierte al tipo especificado
      value.map! do |v|
        if v.nil?
          default_value
        else
          case type
            when :float32
              v.to_f
            when :char
              v.to_s[0...length]
            else
              v.to_i
          end
        end
      end

      trim(value, bit_length, sign) # Se asegura de que los valores esten dentro de los rangos permitidos pra el tipo de dato declarado
      value.fill(default_value, value.length...count) # Completa los elementos faltantes del array con default_value
    end

    def check_value(value)
      check(@type, @count, @length, @bit_length, @sign, @default_value, value)
    end

    # Los datos siempre vienen en bytes
    def check_raw_value(value)
      check(:uint8, size, 1, 8, :unsigned, 0, value)
    end

    def trim(value, bit_length, sign)
      # Recorta los valores según el bit_length
      value.map! do |v|
        if sign == :signed
          [-2**(bit_length-1),[v.to_i,2**(bit_length-1)-1].min].max
        elsif sign == :unsigned
          [0,[v.to_i,2**(bit_length)-1].min].max
        else
          v
        end
      end
    end

    def value=(value)
      @value = check_value(value)
    end
  end

  class Int8 < Type
    def initialize(count=1, length=1)
      super :int8, 8, :signed, count
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      @raw_value = @value
    end

    def load(value)
      self.value = check_raw_value(value)
      @raw_value = @value
    end
  end

  class Int16 < Type
    def initialize(count=1, length=1)
      super :int16, 16, :signed, count
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      @raw_value = @value.pack('v*').unpack('C*')
    end

    def load(value)
      self.value = check_raw_value(value).pack('C*').unpack('v*')
      @value
    end
  end

  class Int32 < Type
    def initialize(count=1, length=1)
      super :int32, 32, :signed, count
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      @raw_value = @value.pack('V*').unpack('C*')
    end

    def load(value)
      self.value = check_raw_value(value).pack('C*').unpack('V*') if !value.nil?
      @value
    end
  end

  class UInt16 < Type
    def initialize(count=1, length=1)
      super :uint16, 16, :unsigned, count
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      @raw_value = @value.pack('v*').unpack('C*')
    end

    def load(value)
      @raw_value = check_raw_value(value)
      self.value = @raw_value.pack('C*').unpack('v*')
      @value1 
    end
  end

  class UInt32 < Type
    def initialize(count=1, length=1)
      super :uint32, 32, :unsigned, count
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      @raw_value = @value.pack('l*').unpack('C*')
    end

    def load(value)
      self.value = check_raw_value(value).pack('C*').unpack('l*') if !value.nil?
      @value
    end
  end

  class UInt8 < Type
    def initialize(count=1, length=1)
      super :uint8, 8, :unsigned, count
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      @raw_value = @value
    end

    def load(value)
      self.value = check_raw_value(value)
      @value
    end
  end

  class BitField < Type
    def initialize(count=1, length=8)
      length = 32 if length > 32
      super :bitfield, length, :unsigned, count
    end

    def format
      if bit_length <= 8 # 8 bits
        'C*'
      elsif bit_length <= 16 # 16 bits
        'v*'
      else # 32 bits
        'l*'
      end
    end

    def word_length
      if bit_length <= 8 # 8 bits
        8
      elsif bit_length <= 16 # 16 bits
        16
      else # 32 bits
        32
      end
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      data = @value.pack(format).unpack('b*').first.chars.each_slice(word_length).map(&:join).map{|n| n.slice(0,bit_length)}
      @raw_value = [data.join].pack('b*').unpack('C*')
    end

    def load(value)
      self.value = check_raw_value(value).pack('C*').unpack('b*').first.chars.slice(0,@bit_length*@count).each_slice(bit_length).map(&:join).map{|n| [n].pack('b*').unpack('C*').first}
      @value
    end
  end

  class Char < Type
    def initialize(count=1, length=1)
      super :char, 8, nil, count, length, "\x0"
    end

    #@todo: corregir lo de abajo:
    def self.serialize(value)
      var = Char.new
      var.value = value
      var.serialize
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      @raw_value = @value.map{|v| v.ljust(@length, @default_value).slice(0,@length).unpack('C*')}
    end

    def load(value)
      self.value = check_raw_value(value).pack('C*').unpack("Z#{@length}") if !value.nil?
      @value
    end
  end

  class Bool < Type
    def initialize(count=1, length=1)
      super :bool, 1, :unsigned, count
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      @raw_value = [@value.join].pack('b*').unpack('C*')
    end

    def load(value)
      self.value = check_raw_value(value).pack('C*').unpack('b*').first.slice(0,size*8).split('').map(&:to_i) if !value.nil?
      @value
    end
  end

  class Float32 < Type
    def initialize(count=1, length=1)
      super :float32, 32, nil, count, length, 0.0
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      @raw_value = @value.pack('e*').unpack('C*')
    end

    def load(value)
      self.value = check_raw_value(value).pack('C*').unpack('e*') if !value.nil?
      @value
    end
  end
end