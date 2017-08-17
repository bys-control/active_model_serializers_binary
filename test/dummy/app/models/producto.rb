# == Schema Information
#
# Table name: productos
#
#  id              :integer          not null, primary key
#  uid             :integer
#  silo            :integer
#  nombre          :string
#  total_acumulado :integer
#  bits1           :boolean
#  bits2           :boolean
#  ffloat          :float
#  variable        :string
#  created_at      :datetime
#  updated_at      :datetime
#

class Producto < ActiveRecord::Base
	include ActiveModel::Serializers::Binary

	char :nombre, count: 1, length: 20
	nest :tipo, coder: Tipo
end
