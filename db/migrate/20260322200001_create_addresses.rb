class CreateAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :addresses do |t|
      t.references :customer_profile, null: false, foreign_key: true
      t.string :label
      t.string :street, null: false
      t.string :city, null: false
      t.string :state, null: false
      t.string :zip_code, null: false
      t.string :country, null: false, default: "MX"
      t.boolean :is_default, default: false, null: false

      t.timestamps
    end
  end
end
