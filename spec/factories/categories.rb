FactoryBot.define do
  factory :category do
    name { Faker::Commerce.department(max: 1) }
    slug { nil } # Let FriendlyId generate it
    description { Faker::Lorem.paragraph }
    image_url { Faker::Internet.url }
    position { Faker::Number.between(from: 0, to: 10) }

    trait :with_parent do
      association :parent_category, factory: :category
    end
  end
end
