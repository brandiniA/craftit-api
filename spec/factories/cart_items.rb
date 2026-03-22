FactoryBot.define do
  factory :cart_item do
    association :customer_profile
    association :product
    quantity { Faker::Number.between(from: 1, to: 5) }
  end
end
