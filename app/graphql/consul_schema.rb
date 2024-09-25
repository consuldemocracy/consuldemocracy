class ConsulSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  max_depth 8
end
