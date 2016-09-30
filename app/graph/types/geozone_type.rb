GeozoneType = GraphQL::ObjectType.define do
  name "Geozone"
  description "A geozone entry, returns basic geozone information"
  # Expose fields associated with Geozone model
  field :id, !types.ID, "The id of this geozone"
  field :name, types.String, "The name of this geozone"
  field :html_map_coordinates, types.String, "HTML map coordinates of this geozone"
  field :external_code, types.String, "The external code of this geozone"
  field :census_code, types.String, "The census code of this geozone"
end
