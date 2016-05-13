require_relative 'base_type.rb'

module DataTypes

  class Int8 < Type
    def initialize(options = {})
      super :bit_length => 8, :sign => :signed, :count => options[:count]
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
      super :bit_length => 16, :sign => :signed, :count => options[:count]
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
      super :bit_length => 32, :sign => :signed, :count => options[:count]
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
      super :bit_length => 16, :sign => :unsigned, :count => options[:count]
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
      super :bit_length => 32, :sign => :unsigned, :count => options[:count]
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
      super :bit_length => 8, :sign => :unsigned, :count => options[:count]
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
    def initialize(options = {})
      length = 32 if length > 32
      super :bit_length => length, :sign => :unsigned, :count => options[:count]
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
      super :bit_length => 8, :sign => nil, :count => options[:count], :length => options[:length], :default_value => "\x0"
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
      super :bit_length => 1, :count => options[:count], :default_value => false
    end

    def dump(value=nil)
      self.value = value if !value.nil?
      @raw_value = Array(@value.map{|v| v ? 1 : 0}.join).pack('b*').unpack('C*')
    end

    def load(value)
      self.value = check_raw_value(value).pack('C*').unpack('b*').first.slice(0,size*8).split('').map(&:to_i) if !value.nil?
      @value
    end
  end

  class Float32 < Type
    def initialize(options = {})
      super :bit_length => 32, :sign => nil, :count => options[:count], :default_value => 0.0
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