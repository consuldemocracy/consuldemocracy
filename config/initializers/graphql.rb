api_config = YAML.load_file('./config/api.yml')
api_type_definitions = GraphQL::ApiTypesCreator::parse_api_config_file(api_config)

api_types_creator = GraphQL::ApiTypesCreator.new(api_type_definitions)
created_api_types = api_types_creator.create

query_type_creator = GraphQL::QueryTypeCreator.new(created_api_types)
QueryType = query_type_creator.create

ConsulSchema = GraphQL::Schema.define do
  query QueryType
  max_depth 12

  resolve_type -> (object, ctx) do
    type_name = object.class.name # look up types by class name
    ConsulSchema.types[type_name]
  end
end
