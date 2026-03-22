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

FactoryBot.define do
  factory :review do
    association :customer_profile
    association :product
    rating { Faker::Number.between(from: 1, to: 5) }
    title { Faker::Lorem.sentence(word_count: 4) }
    body { Faker::Lorem.paragraph(sentence_count: 3) }
    is_verified_purchase { false }

    trait :verified do
      is_verified_purchase { true }
    end
  end
end
