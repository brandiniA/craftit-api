class AddressSerializer
  include JSONAPI::Serializer

  attributes :label, :street, :city, :state, :zip_code, :country, :is_default
end
