require_relative 'base_type.rb'

module DataTypes

  class Int8 < BaseType
    def initialize(options = {})
      super options.merge :bit_length => 8, :sign => :signed
    end

    def dump(value=nil)
      before_dump( value )
      @raw_value = @value
    end

    def load(raw_value)
      self.value = check_raw_value(raw_value)
      after_load
    end
  end

  class Int16 < BaseType
    def initialize(options = {})
      super options.merge :bit_length => 16, :sign => :signed
    end

    def dump(value=nil)
      before_dump( value )
      @raw_value = @value.pack('v*').unpack('C*')
    end

    def load(raw_value)
      self.value = check_raw_value(raw_value).pack('C*').unpack('v*')
      after_load
    end
  end

  class Int32 < BaseType
    def initialize(options = {})
      super options.merge :bit_length => 32, :sign => :signed
    end

    def dump(value=nil)
      before_dump( value )
      @raw_value = @value.pack('V*').unpack('C*')
    end

    def load(raw_value)
      self.value = check_raw_value(raw_value).pack('C*').unpack('V*') if !value.nil?
      after_load
    end
  end

  class UInt16 < BaseType
    def initialize(options = {})
      super options.merge :bit_length => 16, :sign => :unsigned
    end

    def dump(value=nil)
      before_dump( value )
      @raw_value = @value.pack('v*').unpack('C*')
    end

    def load(raw_value)
      @raw_value = check_raw_value(raw_value)
      self.value = @raw_value.pack('C*').unpack('v*')
      after_load
    end
  end

  class UInt32 < BaseType
    def initialize(options = {})
      super options.merge :bit_length => 32, :sign => :unsigned
    end

    def dump(value=nil)
      before_dump( value )
      @raw_value = @value.pack('l*').unpack('C*')
    end

    def load(raw_value)
      self.value = check_raw_value(raw_value).pack('C*').unpack('l*') if !value.nil?
      after_load
    end
  end

  class UInt8 < BaseType
    def initialize(options = {})
      super options.merge :bit_length => 8, :sign => :unsigned
    end

    def dump(value=nil)
      before_dump( value )
      @raw_value = @value
    end

    def load(raw_value)
      self.value = check_raw_value(raw_value)
      after_load
    end
  end

  class BitField < BaseType
    def initialize(options = {})
      length = options[:bin_length].blank? ? 1 : (options[:bin_length] > 32 ? 32 : options[:bin_length])
      super options.merge :bit_length => length, :sign => :unsigned
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
      before_dump( value )
      data = @value.pack(format).unpack('b*').first.chars.each_slice(word_length).map(&:join).map{|n| n.slice(0,bit_length)}
      @raw_value = [data.join].pack('b*').unpack('C*')
    end

    def load(raw_value)
      self.value = check_raw_value(raw_value).pack('C*').unpack('b*').first.chars.slice(0,@bit_length*@count).each_slice(bit_length).map(&:join).map{|n| [n].pack('b*').unpack('C*').first}
      after_load
    end
  end

  class Char < BaseType
    def initialize(options = {})
      super options.merge :bit_length => 8, :sign => nil, :default_value => "\x0"
    end

    def dump(value=nil)
      before_dump( value )
      @raw_value = @value.map{|v| v.ljust(@length, @default_value).slice(0,@length).unpack('C*')}
    end

    def load(raw_value)
      self.value = check_raw_value(raw_value).pack('C*').unpack("Z#{@length}") if !value.nil?
      after_load
    end
  end

  class Bool < BaseType
    def initialize(options = {})
      super options.merge :bit_length => 1, :default_value => false
    end

    def dump(value=nil)
      before_dump( value )
      @raw_value = Array(@value.map{|v| v ? 1 : 0}.join).pack('b*').unpack('C*')
    end

    def load(raw_value)
      self.value = check_raw_value(raw_value).pack('C*').unpack('b*').first.slice(0,size*8).split('').map(&:to_i) if !value.nil?
      after_load
    end
  end

  class Float32 < BaseType
    def initialize(options = {})
      super options.merge :bit_length => 32, :sign => nil, :default_value => 0.0
    end

    def dump(value=nil)
      before_dump( value )
      @raw_value = @value.pack('e*').unpack('C*')
    end

    def load(raw_value)
      self.value = check_raw_value(raw_value).pack('C*').unpack('e*') if !value.nil?
      after_load
    end
  end
end