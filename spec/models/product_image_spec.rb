require "rails_helper"

RSpec.describe ProductImage, type: :model do
  describe "validations" do
    subject { build(:product_image) }

    it { is_expected.to be_valid }

    it "requires url" do
      subject.url = nil
      expect(subject).not_to be_valid
    end

    it "requires product" do
      subject.product = nil
      expect(subject).not_to be_valid
    end
  end

  describe "scopes" do
    it ".ordered returns images sorted by position" do
      product = create(:product)
      img2 = create(:product_image, product: product, position: 2)
      img1 = create(:product_image, product: product, position: 1)

      expect(described_class.ordered).to eq([ img1, img2 ])
    end
  end
end
