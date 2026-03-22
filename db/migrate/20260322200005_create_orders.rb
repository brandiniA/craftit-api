class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :customer_profile, null: false, foreign_key: true
      t.string :order_number, null: false
      t.integer :status, default: 0, null: false
      t.decimal :subtotal, precision: 10, scale: 2, null: false
      t.decimal :shipping_cost, precision: 10, scale: 2, default: 0, null: false
      t.decimal :tax, precision: 10, scale: 2, default: 0, null: false
      t.decimal :tax_rate_snapshot, precision: 5, scale: 4, default: 0.16, null: false
      t.decimal :total, precision: 10, scale: 2, null: false
      t.string :customer_name_snapshot
      t.string :customer_email_snapshot
      t.jsonb :shipping_address_snapshot, default: {}

      t.timestamps
    end

    add_index :orders, :order_number, unique: true
  end
end
