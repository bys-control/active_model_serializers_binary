class Type
	include ActiveModel::Serializers::Binary

	int16 :product_id
	char :name, count: 1, length: 20

end
