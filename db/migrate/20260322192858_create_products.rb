class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.decimal :compare_at_price, precision: 10, scale: 2
      t.string :sku, null: false
      t.references :category, foreign_key: true, null: true
      t.boolean :is_active, default: true, null: false
      t.boolean :is_featured, default: false, null: false

      t.timestamps
    end

    add_index :products, :slug, unique: true
    add_index :products, :sku, unique: true
    add_index :products, [ :category_id, :is_active ]
  end
end
