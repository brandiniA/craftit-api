# <rails-lens:schema:begin>
# table = "addresses"
# database_dialect = "PostgreSQL"
#
# columns = [
#   { name = "id", type = "integer", pk = true, null = false },
#   { name = "city", type = "string", null = false },
#   { name = "country", type = "string", null = false, default = "MX" },
#   { name = "created_at", type = "datetime", null = false },
#   { name = "customer_profile_id", type = "integer", null = false },
#   { name = "is_default", type = "boolean", null = false },
#   { name = "label", type = "string" },
#   { name = "state", type = "string", null = false },
#   { name = "street", type = "string", null = false },
#   { name = "updated_at", type = "datetime", null = false },
#   { name = "zip_code", type = "string", null = false }
# ]
#
# indexes = [
#   { name = "index_addresses_on_customer_profile_id", columns = ["customer_profile_id"] }
# ]
#
# foreign_keys = [
#   { column = "customer_profile_id", references_table = "customer_profiles", references_column = "id", name = "fk_rails_c5f6184b76" }
# ]
#
# notes = ["label:NOT_NULL", "state:DEFAULT", "city:LIMIT", "country:LIMIT", "label:LIMIT", "state:LIMIT", "street:LIMIT", "zip_code:LIMIT", "state:INDEX", "zip_code:INDEX"]
# <rails-lens:schema:end>
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
