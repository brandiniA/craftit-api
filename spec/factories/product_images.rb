FactoryBot.define do
  factory :product_image do
    association :product
    url { "https://example.supabase.co/storage/v1/object/public/#{SecureRandom.hex(8)}.jpg" }
    alt_text { Faker::Lorem.sentence(word_count: 3) }
    position { Faker::Number.between(from: 0, to: 5) }
  end
end
