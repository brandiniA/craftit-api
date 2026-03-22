class ShipmentSerializer
  include JSONAPI::Serializer

  attributes :carrier, :tracking_number, :tracking_url,
    :status, :estimated_delivery, :created_at, :updated_at
end
