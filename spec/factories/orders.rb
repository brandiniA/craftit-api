FactoryBot.define do
  factory :order do
    association :customer_profile
    sequence(:order_number) { |n| "CRA-#{Date.current.strftime('%Y%m%d')}-#{format('%04d', n)}" }
    status { :pending }
    subtotal { Faker::Commerce.price(range: 100..5000.0) }
    shipping_cost { Faker::Commerce.price(range: 50..200.0) }
    tax_rate_snapshot { 0.16 }
    tax { (subtotal * tax_rate_snapshot).round(2) }
    total { (subtotal + shipping_cost + tax).round(2) }
    customer_name_snapshot { Faker::Name.name }
    customer_email_snapshot { Faker::Internet.email }
    shipping_address_snapshot do
      {
        street: Faker::Address.street_address,
        city: Faker::Address.city,
        state: Faker::Address.state,
        zip_code: Faker::Address.zip_code,
        country: "MX"
      }
    end

    trait :paid do
      status { :paid }
    end

    trait :processing do
      status { :processing }
    end

    trait :shipped do
      status { :shipped }
    end

    trait :delivered do
      status { :delivered }
    end

    trait :cancelled do
      status { :cancelled }
    end
  end
end
