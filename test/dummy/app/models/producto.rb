# == Schema Information
#
# Table name: productos
#
#  id              :integer          not null, primary key
#  uid             :integer
#  silo            :integer
#  nombre          :string(255)
#  total_acumulado :integer
#  bits1           :boolean
#  bits2           :boolean
#  ffloat          :float
#  variable        :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class Producto < ActiveRecord::Base
	include ActiveModel::Serializers::Binary

	int16 :uid
	int16 :silo
	char :nombre, count: 1, length: 20
	int32 :total_acumulado
	bool :bits1
	bool :bits2
	bool :bits3
	bool :bits4
	bool :bits5
	bool :bits6
	bool :bits7
	bool :bits8
	bool :bits9
	bool :bits10
	bool :bits11
	bool :bits12
	bool :bits13
	bool :bits14
	bool :bits15
	bool :bits16
	float32 :ffloat
	char :variable, count: 1, length: 20 do |field, mode|
		puts (mode.to_s + ': variable block').blue
	end
	int32 :test, count: 10 # No existe en la DB
end
