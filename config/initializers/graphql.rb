if ActiveRecord::Base.connection.tables.any?
  api_config = YAML.load_file('./config/api.yml')
  API_TYPE_DEFINITIONS = GraphQL::ApiTypesCreator::parse_api_config_file(api_config)
end
