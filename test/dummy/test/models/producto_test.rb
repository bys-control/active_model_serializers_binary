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

require 'test_helper'

class ProductoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
