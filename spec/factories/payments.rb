FactoryBot.define do
  factory :payment do
    association :order
    provider { "mercadopago" }
    provider_payment_id { nil }
    status { :pending }
    amount { Faker::Commerce.price(range: 100..5000.0) }
    currency { "MXN" }

    trait :completed do
      status { :completed }
      provider_payment_id { "MP-#{SecureRandom.hex(8)}" }
    end

    trait :failed do
      status { :failed }
    end

    trait :refunded do
      status { :refunded }
      provider_payment_id { "MP-#{SecureRandom.hex(8)}" }
    end
  end
end
