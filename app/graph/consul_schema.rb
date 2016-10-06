ConsulSchema = GraphQL::Schema.define do
  query QueryRoot

  # Reject deeply-nested queries
  max_depth 7

  resolve_type -> (object, ctx) {
    # look up types by class name
    type_name = object.class.name
    ConsulSchema.types[type_name]
  }
end
