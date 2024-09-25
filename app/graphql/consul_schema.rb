class ConsulSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  default_max_page_size 25
  max_complexity 2500
  max_depth 8
end
