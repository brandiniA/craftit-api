class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :customer_profile, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :rating, null: false
      t.string :title
      t.text :body
      t.boolean :is_verified_purchase, default: false, null: false

      t.timestamps
    end
  end
end
