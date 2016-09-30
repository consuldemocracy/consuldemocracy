ConsulSchema = GraphQL::Schema.define do
  query QueryRoot

  resolve_type -> (object, ctx) {
    # look up types by class name
    type_name = object.class.name
    ConsulSchema.types[type_name]
  }
end
