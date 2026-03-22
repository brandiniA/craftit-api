class CreateCustomerProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_profiles do |t|
      t.string :auth_user_id, null: false
      t.string :phone
      t.date :birth_date

      t.timestamps
    end

    add_index :customer_profiles, :auth_user_id, unique: true
  end
end
