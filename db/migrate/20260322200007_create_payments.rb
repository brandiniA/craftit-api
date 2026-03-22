class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :provider_payment_id
      t.integer :status, default: 0, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, default: "MXN", null: false

      t.timestamps
    end
  end
end
