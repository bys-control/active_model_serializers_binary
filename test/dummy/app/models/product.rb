class Product
	include ActiveModel::Serializers::Binary

	endianess :big
	align :dword

	int8 :int8
	int16 :int16
	int16le :int16le
	int16be :int16be
	int32 :int32
	int32le :int32le
	int32be :int32be
	uint8 :uint8
	uint16 :uint16
	uint16le :uint16le
	uint16be :uint16be
	uint32 :uint32
	uint32le :uint32le
	uint32be :uint32be
	bitfield :bitfield
	float32 :float32
	float64 :float64
	char :char
	bool :bool
	nest :type, coder: Type
end
