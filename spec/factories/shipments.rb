FactoryBot.define do
  factory :shipment do
    association :order
    carrier { %w[DHL FedEx Estafeta].sample }
    tracking_number { SecureRandom.hex(8).upcase }
    tracking_url { "https://tracking.example.com/#{tracking_number}" }
    status { :preparing }
    estimated_delivery { Faker::Date.forward(days: 7) }
  end
end
