class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.string :product_name_snapshot, null: false
      t.decimal :price_snapshot, precision: 10, scale: 2, null: false
      t.integer :quantity, null: false

      t.timestamps
    end
  end
end
