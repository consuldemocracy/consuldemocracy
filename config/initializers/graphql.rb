API_TYPE_DEFINITIONS = {
  User     => {
    id:         :integer,
    username:   :string,
    gender:     :string,
    geozone_id: :integer,
    geozone:    Geozone
  },
  Debate   => {
    id:                 :integer,
    title:              :string,
    description:        :string,
    created_at:         :string,
    cached_votes_total: :integer,
    cached_votes_up:    :integer,
    cached_votes_down:  :integer,
    comments_count:     :integer,
    hot_score:          :integer,
    confidence_score:   :integer,
    geozone_id:         :integer,
    geozone:            Geozone,
    comments:           [Comment],
    public_author:      User
  },
  Proposal => {
    id:                 :integer,
    title:              :string,
    description:        :sting,
    external_url:       :string,
    cached_votes_up:    :integer,
    comments_count:     :integer,
    hot_score:          :integer,
    confidence_score:   :integer,
    created_at:         :string,
    summary:            :string,
    video_url:          :string,
    geozone_id:         :integer,
    retired_at:         :string,
    retired_reason:     :string,
    retired_explanation: :string,
    geozone:            Geozone,
    comments:           [Comment],
    proposal_notifications: [ProposalNotification],
    public_author:      User
  },
  Comment  => {
    id:                 :integer,
    commentable_id:     :integer,
    commentable_type:   :string,
    body:               :string,
    created_at:         :string,
    cached_votes_total: :integer,
    cached_votes_up:    :integer,
    cached_votes_down:  :integer,
    ancestry:           :string,
    confidence_score:   :integer,
    public_author:      User
  },
  Geozone  => {
    id:   :integer,
    name: :string
  },
  ProposalNotification => {
    title:          :string,
    body:           :string,
    proposal_id:    :integer,
    created_at:     :string,
    proposal:       Proposal
  },
  Tag => {
    id:             :integer,
    name:           :string,
    taggings_count: :integer,
    kind:           :string
  },
  Vote => {
    votable_id:     :integer,
    votable_type:   :string,
    created_at:     :string,
    public_voter:   User
  }
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
    if API_TYPE_DEFINITIONS[model][:id]
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
