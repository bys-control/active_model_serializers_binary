module DataTypes

  class BaseType

    attr_accessor :raw_value, :bit_length, :type, :sign, :count, :length, :value, :name, :parent, :endianess

    def initialize(options = {})
      @default_value = options[:default_value].nil? ? 0 : options[:default_value]
      @raw_value = nil
      @bit_length = options[:bit_length]        # Cantidad de bits del tipo de dato
      @type = type
      @sign = options[:sign]                    # :signed / :unsigned
      @count = options[:count] || 1             # Cantidad de elementos del array
      @length = options[:length]  || 1          # En char y bitfield especifica la longitud del campo. Ignorado para el resto de los tipos
      @value = check_value( @default_value )
      @block = options[:block]
      @name = options[:name]
      @parent = options[:parent]
      @endianess = options[:endianess] || :little
    end

    def to_s
      @value.to_s
    end

    def type
      self.class.to_s.split('::').last.downcase.to_sym
    end

    # Return size of object in bytes
    def size
      (@bit_length*@length*@count)/8.0
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
            when :float32, :float64
              v.to_f
            when :char
              v.to_s[0...length]
            when :bool
              (v.in? [1, true]) ? true : false
            when :nest
              v
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
        :count => (size < 1 ? 1 : size),
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


    #
    # Se ejecuta antes de serializar los datos
    #
    # @param [Object] value valor del objeto a serializar original
    #
    # @return [Array] nuevo valor del objeto a serializar
    # 
    def before_dump(value)
      self.value = value if !value.nil?
      if !@block.nil?
        value = @parent.instance_exec( self, :dump, &@block )
      end
      self.value = value if !value.nil?
    end

    #
    # Se ejecuta después de deserializar los datos. @value contiene los datos deserializados
    #
    #
    # @return [Array] Array con los datos deserializados
    # 
    def after_load
      if !@block.nil?
        @parent.instance_exec( self, :load, &@block )
      end
      @value
    end
  end
end