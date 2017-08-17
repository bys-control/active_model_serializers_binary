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
	bool :bits3, virtual: true
	bool :bits4, virtual: true
	bool :bits5, virtual: true
	bool :bits6, virtual: true
	bool :bits7, virtual: true
	bool :bits8, virtual: true
	bool :bits9, virtual: true
	bool :bits10, virtual: true
	bool :bits11, virtual: true
	bool :bits12, virtual: true
	bool :bits13, virtual: true
	bool :bits14, virtual: true
	bool :bits15, virtual: true
	bool :bits16, virtual: true
	float32 :ffloat
	char :variable, count: 1, length: 20 do |field, mode|
		puts (mode.to_s + ': variable block').blue
	end
	int32 :test, count: 10, virtual: true # No existe en la DB
	nest :tipo, coder: Tipo
end
