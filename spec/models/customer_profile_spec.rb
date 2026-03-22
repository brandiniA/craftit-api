# == Schema Information
#
# Table name: customer_profiles
#
#  id           :integer          not null, primary key
#  auth_user_id :string           not null
#  phone        :string
#  birth_date   :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_customer_profiles_on_auth_user_id  (auth_user_id) UNIQUE
#

require "rails_helper"

RSpec.describe CustomerProfile, type: :model do
  describe "validations" do
    subject { build(:customer_profile) }

    it { is_expected.to be_valid }

    it "requires auth_user_id" do
      subject.auth_user_id = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:auth_user_id]).to include("can't be blank")
    end

    it "requires unique auth_user_id" do
      create(:customer_profile, auth_user_id: "user-123")
      subject.auth_user_id = "user-123"
      expect(subject).not_to be_valid
      expect(subject.errors[:auth_user_id]).to include("has already been taken")
    end
  end
end
