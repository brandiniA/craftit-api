require "rails_helper"

RSpec.describe Address, type: :model do
  describe "validations" do
    subject { build(:address) }

    it { is_expected.to be_valid }

    %i[street city state zip_code country].each do |field|
      it "requires #{field}" do
        subject.send(:"#{field}=", nil)
        expect(subject).not_to be_valid
      end
    end
  end

  describe "associations" do
    it "belongs to customer_profile" do
      profile = create(:customer_profile)
      address = create(:address, customer_profile: profile)
      expect(address.customer_profile).to eq(profile)
    end
  end
end
