class CreateProductos < ActiveRecord::Migration
  def change
    create_table :productos do |t|
      t.integer :uid
      t.integer :silo
      t.string :nombre
      t.integer :total_acumulado
      t.boolean :bits1
      t.boolean :bits2
      t.float :ffloat
      t.string :variable

      t.timestamps
    end
  end
end
