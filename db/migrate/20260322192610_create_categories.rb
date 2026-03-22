class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :image_url
      t.references :parent_category, foreign_key: { to_table: :categories }, null: true
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :categories, :slug, unique: true
  end
end
