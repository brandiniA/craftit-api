# == Schema Information
#
# Table name: order_items
#
#  id                    :integer          not null, primary key
#  order_id              :integer          not null
#  product_id            :integer          not null
#  product_name_snapshot :string           not null
#  price_snapshot        :decimal(10, 2)   not null
#  quantity              :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_order_items_on_order_id    (order_id)
#  index_order_items_on_product_id  (product_id)
#

require "rails_helper"

RSpec.describe OrderItem, type: :model do
  describe "validations" do
    subject { build(:order_item) }

    it { is_expected.to be_valid }

    it "requires quantity greater than 0" do
      subject.quantity = 0
      expect(subject).not_to be_valid
    end

    it "requires product_name_snapshot" do
      subject.product_name_snapshot = nil
      expect(subject).not_to be_valid
    end

    it "requires price_snapshot" do
      subject.price_snapshot = nil
      expect(subject).not_to be_valid
    end
  end

  describe "#subtotal" do
    it "calculates price_snapshot times quantity" do
      item = build(:order_item, price_snapshot: 299.99, quantity: 3)
      expect(item.subtotal).to eq(899.97)
    end
  end
end
