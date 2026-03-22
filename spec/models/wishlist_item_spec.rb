# == Schema Information
#
# Table name: wishlist_items
#
#  id                  :integer          not null, primary key
#  customer_profile_id :integer          not null
#  product_id          :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_wishlist_items_on_customer_profile_id                 (customer_profile_id)
#  index_wishlist_items_on_customer_profile_id_and_product_id  (customer_profile_id,product_id) UNIQUE
#  index_wishlist_items_on_product_id                          (product_id)
#

require "rails_helper"

RSpec.describe WishlistItem, type: :model do
  describe "validations" do
    subject { build(:wishlist_item) }

    it { is_expected.to be_valid }

    it "prevents duplicate product in wishlist" do
      profile = create(:customer_profile)
      product = create(:product)
      create(:wishlist_item, customer_profile: profile, product: product)

      duplicate = build(:wishlist_item, customer_profile: profile, product: product)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:product_id]).to include("has already been taken")
    end
  end
end
