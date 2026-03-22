# == Schema Information
#
# Table name: customer_profiles
#
#  id           :integer          not null, primary key
#  auth_user_id :string           not null
#  phone        :string
#  birth_date   :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_customer_profiles_on_auth_user_id  (auth_user_id) UNIQUE
#

FactoryBot.define do
  factory :customer_profile do
    auth_user_id { SecureRandom.uuid }
    phone { Faker::PhoneNumber.phone_number }
    birth_date { Faker::Date.birthday(min_age: 18, max_age: 65) }
  end
end
