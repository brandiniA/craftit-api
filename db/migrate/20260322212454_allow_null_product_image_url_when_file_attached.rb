class AllowNullProductImageUrlWhenFileAttached < ActiveRecord::Migration[8.1]
  def change
    change_column_null :product_images, :url, true
  end
end
