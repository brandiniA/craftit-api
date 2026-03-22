# == Schema Information
#
# Table name: reviews
#
#  id                   :integer          not null, primary key
#  customer_profile_id  :integer          not null
#  product_id           :integer          not null
#  rating               :integer          not null
#  title                :string
#  body                 :text
#  is_verified_purchase :boolean          default(FALSE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_reviews_on_customer_profile_id  (customer_profile_id)
#  index_reviews_on_product_id           (product_id)
#

require "rails_helper"

RSpec.describe Review, type: :model do
  describe "validations" do
    subject { build(:review) }

    it { is_expected.to be_valid }

    it "requires rating" do
      subject.rating = nil
      expect(subject).not_to be_valid
    end

    it "requires rating between 1 and 5" do
      subject.rating = 0
      expect(subject).not_to be_valid

      subject.rating = 6
      expect(subject).not_to be_valid

      subject.rating = 3
      expect(subject).to be_valid
    end

    it "requires integer rating" do
      subject.rating = 3.5
      expect(subject).not_to be_valid
    end
  end
end
