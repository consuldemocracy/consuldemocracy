API_TYPE_DEFINITIONS = {
  User => %I[ id username ],
  Proposal => %I[ id title description author_id author created_at ]
}

api_types = {}

API_TYPE_DEFINITIONS.each do |model, fields|
  api_types[model] = GraphQL::TypeCreator.create(model, fields, api_types)
end

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

QueryRoot = GraphQL::ObjectType.define do
  name "Query"
  description "The query root for this schema"

  field :proposal do
    type api_types[Proposal]
    description "Find a Proposal by id"
    argument :id, !types.ID
    resolve -> (object, arguments, context) {
      Proposal.find(arguments["id"])
    }
  end

  field :proposals do
    type types[api_types[Proposal]]
    description "Find all Proposals"
    resolve -> (object, arguments, context) {
      Proposal.all
    }
  end

end
