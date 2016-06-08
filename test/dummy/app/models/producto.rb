class Producto < ActiveRecord::Base
	include ActiveModel::Serializers::Binary

	int16 :uid
	int16 :silo
	char :nombre, count: 1, length: 20
	int32 :total_acumulado
	bool :bits1
	bool :bits2
	float32 :ffloat
	char :variable, count: 1, length: 20 do |field, mode|
		puts (mode.to_s + ': variable block').blue
	end
end