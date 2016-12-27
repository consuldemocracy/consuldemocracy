API_TYPE_DEFINITIONS = {
  User     => %I[ id username proposals ],
  Debate   => %I[ id title description created_at cached_votes_total cached_votes_up cached_votes_down comments_count hot_score confidence_score geozone_id geozone comments public_author ],
  Proposal => %I[ id title description external_url cached_votes_up comments_count hot_score confidence_score created_at summary video_url geozone_id retired_at retired_reason retired_explanation geozone comments public_author ],
  Comment  => %I[ id commentable_id commentable_type body created_at cached_votes_total cached_votes_up cached_votes_down ancestry confidence_score public_author ],
  Geozone  => %I[ id name ]
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
      resolve -> (object, arguments, context) do
        if model.respond_to?(:public_for_api)
          model.public_for_api.find(arguments["id"])
        else
          model.find(arguments["id"])
        end
      end
    end

    # create an entry filed to retrive a paginated collection
    connection model.name.underscore.pluralize.to_sym, created_type.connection_type do
      description "Find all #{model.model_name.human.pluralize}"
      resolve -> (object, arguments, context) do
        if model.respond_to?(:public_for_api)
          model.public_for_api
        else
          model.all
        end
      end
    end

  end
end
