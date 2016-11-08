class TypeBuilder
  attr_reader :filter_strategy, :graphql_models

  def initialize(graphql_models, options = {})
    @graphql_models = graphql_models
    @graphql_types = {}

    # determine filter strategy for this field
    if (options[:filter_strategy] == :blacklist)
      @filter_strategy = :blacklist
    else
      @filter_strategy = :whitelist
    end

    create_all_types
  end

  def types
    @graphql_types
  end

private

  def create_all_types
    @graphql_models.keys.each do |model_class|
      @graphql_types[model_class] = create_type(model_class)
    end
  end

  def create_type(model_class)
    type_builder = self

    graphql_type = GraphQL::ObjectType.define do
      em = ExposableModel.new(model_class, filter_strategy: type_builder.filter_strategy, filter_list: type_builder.graphql_models[model_class])

      name(em.name)
      description(em.description)

      em.exposed_fields.each do |column|
        ef = ExposableField.new(column)
        field(ef.name, ef.graphql_type)
      end
    end

    return graphql_type
  end
end

graphql_models = {}

graphql_models.store(User, ['id', 'username'])
graphql_models.store(Proposal, ['id', 'title', 'description', 'author_id', 'created_at'])
graphql_models.store(Debate, ['id', 'title', 'description', 'author_id', 'created_at'])
graphql_models.store(Comment, ['id', 'commentable_id', 'commentable_type', 'body'])
graphql_models.store(Geozone, ['id', 'name', 'html_map_coordinates'])

TYPE_BUILDER = TypeBuilder.new(graphql_models, filter_strategy: :whitelist)
