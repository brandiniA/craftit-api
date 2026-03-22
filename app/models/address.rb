# == Schema Information
#
# Table name: addresses
#
#  id                  :bigint           not null, primary key
#  customer_profile_id :bigint           not null
#  label               :string
#  street              :string           not null
#  city                :string           not null
#  state               :string           not null
#  zip_code            :string           not null
#  country             :string           not null
#  is_default          :boolean          default(FALSE), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_addresses_on_customer_profile_id  (customer_profile_id)
#

class Address < ApplicationRecord
  belongs_to :customer_profile

  validates :street, :city, :state, :zip_code, :country, presence: true
end
