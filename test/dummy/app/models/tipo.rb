# == Schema Information
#
# Table name: tipos
#
#  id          :integer          not null, primary key
#  name        :string
#  producto_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Tipo < ActiveRecord::Base
	include ActiveModel::Serializers::Binary

	int16 :producto_id
	char :name, count: 1, length: 20

end
