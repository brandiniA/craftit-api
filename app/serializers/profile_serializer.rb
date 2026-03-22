class ProfileSerializer
  include JSONAPI::Serializer

  attributes :auth_user_id, :phone, :birth_date, :created_at, :updated_at
end
