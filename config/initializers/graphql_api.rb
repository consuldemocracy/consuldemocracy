module GraphQLApi
  class Loader
    def self.setup
      if ActiveRecord::Base.connection.tables.any?
        api_config = YAML.load_file("./config/api.yml")
        GraphqlController.const_set "API_TYPE_DEFINITIONS",
          GraphQL::ApiTypesCreator::parse_api_config_file(api_config)
      end
    end
  end
end
