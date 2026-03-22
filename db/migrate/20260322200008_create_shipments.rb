class CreateShipments < ActiveRecord::Migration[8.1]
  def change
    create_table :shipments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :carrier
      t.string :tracking_number
      t.string :tracking_url
      t.integer :status, default: 0, null: false
      t.date :estimated_delivery

      t.timestamps
    end
  end
end
