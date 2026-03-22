class ReviewSerializer
  include JSONAPI::Serializer

  attributes :rating, :title, :body, :is_verified_purchase, :created_at

  attribute :reviewer_name do |review|
    name = review.customer_profile&.auth_user_id&.first(8)
    "User #{name}"
  end
end
