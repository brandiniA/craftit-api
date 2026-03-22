FactoryBot.define do
  factory :address do
    association :customer_profile
    label { %w[Home Work Office].sample }
    street { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    zip_code { Faker::Address.zip_code }
    country { "MX" }
    is_default { false }

    trait :default do
      is_default { true }
    end
  end
end
