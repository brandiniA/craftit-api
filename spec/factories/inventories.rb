FactoryBot.define do
  factory :inventory do
    association :product
    stock { Faker::Number.between(from: 10, to: 100) }
    reserved_stock { 0 }
    low_stock_threshold { 5 }

    trait :low_stock do
      stock { 3 }
    end

    trait :out_of_stock do
      stock { 0 }
    end
  end
end
