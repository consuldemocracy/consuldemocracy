UserType = GraphQL::ObjectType.define do
  name "User"
  description "An user entry, returns basic user information"
  # Expose fields associated with User model
  field :id, types.ID, "The id of this user"
  field :created_at, types.String, "Date when this user was created"
  field :username, types.String, "The username of this user"
  field :geozone_id, types.Int, "The ID of the geozone where this user is active"
  field :gender, types.String, "The gender of this user"
  field :date_of_birth, types.String, "The birthdate of this user"

  # Linked resources
  field :geozone, GeozoneType, "Geozone where this user is registered"
end
