class TypeBuilder
  attr_reader :filter_strategy, :graphql_models
  attr_accessor :graphql_types  # contains all generated GraphQL types

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
      em = ExposableModel.new(
        model_class,
        filter_strategy: type_builder.filter_strategy,
        field_filter_list: type_builder.graphql_models[model_class][:fields],
        assoc_filter_list: type_builder.graphql_models[model_class][:associations]
      )

      name(em.name)
      description(em.description)

      em.exposed_fields.each do |column|
        ef = ExposableField.new(column)
        field(ef.name, ef.graphql_type) # returns a GraphQL::Field
      end

      em.exposed_associations.each do |association|
        ea = ExposableAssociation.new(association)
        if ea.type.in? [:has_one, :belongs_to]
          field(ea.name, -> { type_builder.graphql_types[association.klass] })
        elsif ea.type.in? [:has_many]
          field(ea.name, -> {
            types[type_builder.graphql_types[association.klass]]
          })
        end
      end
    end

    return graphql_type
  end
end

graphql_models = {}

graphql_models.store(User, {
  fields: ['id', 'username'],
  associations: ['proposals', 'debates']
})
graphql_models.store(Proposal, {
  fields: ['id', 'title', 'description', 'author_id', 'created_at'],
  associations: ['author']
})
graphql_models.store(Debate, {
  fields: ['id', 'title', 'description', 'author_id', 'created_at'],
  associations: ['author']
})
graphql_models.store(Comment, {
  fields: ['id', 'commentable_id', 'commentable_type', 'body'],
  associations: ['author']
})
graphql_models.store(Geozone, {
  fields: ['id', 'name', 'html_map_coordinates'],
  associations: []
})

TYPE_BUILDER = TypeBuilder.new(graphql_models, filter_strategy: :whitelist)
