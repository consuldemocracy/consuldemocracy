class ConsulSchema < GraphQL::Schema

  use GraphqlDevise::SchemaPlugin.new(
    authenticate_default: false,
    query:            Types::QueryType,
    mutation:         Types::MutationType,
    resource_loaders: [
      GraphqlDevise::ResourceLoader.new( User, operations: {
          register: ::Mutations::Register
      })
    ]
  )
  
  mutation(Types::MutationType)
  query(Types::QueryType)
end
