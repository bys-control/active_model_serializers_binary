module DataTypes
  class Type

    attr_accessor :value, :bit_length

    def initialize(options = {})
      @default_value = options[:default_value] || 0
      @raw_value = nil
      @bit_length = options[:bit_length]        # Cantidad de bits del tipo de dato
      @type = type
      #@type = options[:type]                    # Nombre del tipo de dato
      @sign = options[:sign]                    # :signed / :unsigned
      @count = options[:count] || 1             # Cantidad de elementos del array
      @length = options[:length]  || 1          # En char y bitfield especifica la longitud del campo. Ignorado para el resto de los tipos
      @value = check_value( @default_value )
    end

    def to_s
      @value.to_s
    end

    def type
      self.class.to_s.split('::').last.downcase.to_sym
    end

    # Return size of object in bytes
    def size
      ((@bit_length*@length*@count)/8.0).ceil
    end

    def check( value, options = {} )
      type = options[:type]
      count = options[:count]
      length = options[:length]
      bit_length = options[:bit_length]
      sign = options[:sign]
      default_value = options[:default_value]

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
      check(value, {
        :type => @type,
        :count => @count,
        :length => @length,
        :bit_length => @bit_length,
        :sign => @sign,
        :default_value => @default_value,
        })
    end

    # Los datos siempre vienen en bytes
    def check_raw_value(value)
      check(value, {
        :type => :uint8,
        :count => size,
        :length => 1,
        :bit_length => 8,
        :sign => :unsigned,
        :default_value => 0,
        })
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
    def initialize(options = {})
      count = options[:count] || 1
      length = options[:length] || 1
      super :bit_length => 8, :sign => :signed, :count => count
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
    def initialize(options = {})
      count = options[:count] || 1
      length = options[:length] || 1
      super :bit_length => 16, :sign => :signed, :count => count
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
    def initialize(options = {})
      count = options[:count] || 1
      length = options[:length] || 1
      super :bit_length => 32, :sign => :signed, :count => count
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
    def initialize(options = {})
      count = options[:count] || 1
      length = options[:length] || 1
      super :bit_length => 16, :sign => :unsigned, :count => count
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
    def initialize(options = {})
      count = options[:count] || 1
      length = options[:length] || 1
      super :bit_length => 32, :sign => :unsigned, :count => count
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
    def initialize(options = {})
      count = options[:count] || 1
      length = options[:length] || 1
      super :bit_length => 8, :sign => :unsigned, :count => count
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
      super :bit_length => length, :sign => :unsigned, :count => count
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
    def initialize(options = {})
      count = options[:count] || 1
      length = options[:length] || 1
      super :bit_length => 8, :sign => nil, :count => count, :length => length, :default_value => "\x0"
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
    def initialize(options = {})
      count = options[:count] || 1
      length = options[:length] || 1
      super :bit_length => 1, :sign => :unsigned, :count => count
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
    def initialize(options = {})
      count = options[:count] || 1
      length = options[:length] || 1
      super :bit_length => 32, :sign => nil, :count => count, :length => length, :default_value => 0.0
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