API_TYPE_DEFINITIONS = {
  User     => %I[ id username proposals ],
  Debate   => %I[ id title description author_id author created_at ],
  Proposal => %I[ id title description author_id author created_at ]
}

api_types = {}

API_TYPE_DEFINITIONS.each do |model, fields|
  api_types[model] = GraphQL::TypeCreator.create(model, fields, api_types)
end

ConsulSchema = GraphQL::Schema.define do
  query QueryRoot

  # Reject deeply-nested queries
  max_depth 10

  resolve_type -> (object, ctx) {
    # look up types by class name
    type_name = object.class.name
    ConsulSchema.types[type_name]
  }
end

QueryRoot = GraphQL::ObjectType.define do
  name "Query"
  description "The query root for this schema"

  API_TYPE_DEFINITIONS.each_key do |model|

    # create an entry field to retrive a single object
    field model.name.underscore.to_sym do
      type api_types[model]
      description "Find one #{model.model_name.human} by ID"
      argument :id, !types.ID
      resolve -> (object, arguments, context) {
        model.find(arguments["id"])
      }
    end

    # create an entry filed to retrive a paginated collection
    connection model.name.underscore.pluralize.to_sym, api_types[model].connection_type do
      description "Find all #{model.model_name.human.pluralize}"
      resolve -> (object, arguments, context) {
        model.all
      }
    end

  end
end
