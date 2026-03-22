class CreateInventories < ActiveRecord::Migration[8.1]
  def change
    create_table :inventories do |t|
      t.references :product, null: false, foreign_key: true, index: { unique: true }
      t.integer :stock, default: 0, null: false
      t.integer :reserved_stock, default: 0, null: false
      t.integer :low_stock_threshold, default: 5, null: false

      t.timestamps
    end
  end
end
