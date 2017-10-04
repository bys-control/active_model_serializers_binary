class Silo < ApplicationRecord
	include ActiveModel::Serializers::Binary

	int16 :test
	int32 :test1
end
