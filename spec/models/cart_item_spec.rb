require "rails_helper"

RSpec.describe CartItem, type: :model do
  describe "validations" do
    subject { build(:cart_item) }

    it { is_expected.to be_valid }

    it "requires quantity greater than 0" do
      subject.quantity = 0
      expect(subject).not_to be_valid
    end

    it "requires integer quantity" do
      subject.quantity = 1.5
      expect(subject).not_to be_valid
    end
  end

  describe "#subtotal" do
    it "calculates quantity times product price" do
      product = create(:product, price: 299.99)
      cart_item = build(:cart_item, product: product, quantity: 2)
      expect(cart_item.subtotal).to eq(599.98)
    end
  end
end
