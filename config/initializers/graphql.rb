API_TYPE_DEFINITIONS = {
  User     => %I[ id username proposals organization ],
  Debate   => %I[ id title description author_id author created_at comments ],
  Proposal => %I[ id title description author_id author created_at comments ],
  Comment  => %I[ id body user_id user commentable_id ],
  Organization => %I[ id name ]
}

type_creator = GraphQL::TypeCreator.new

API_TYPE_DEFINITIONS.each do |model, fields|
  type_creator.create(model, fields)
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

  type_creator.created_types.each do |model, created_type|

    # create an entry field to retrive a single object
    field model.name.underscore.to_sym do
      type created_type
      description "Find one #{model.model_name.human} by ID"
      argument :id, !types.ID
      resolve -> (object, arguments, context) {
        model.find(arguments["id"])
      }
    end

    # create an entry filed to retrive a paginated collection
    connection model.name.underscore.pluralize.to_sym, created_type.connection_type do
      description "Find all #{model.model_name.human.pluralize}"
      resolve -> (object, arguments, context) {
        model.all
      }
    end

  end
end
