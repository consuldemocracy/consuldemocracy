require 'graphql'

module GraphQL
  class QueryTypeCreator

    attr_accessor :created_api_types

    def initialize(created_api_types)
      @created_api_types = created_api_types
    end

    def create
      query_type_creator = self

      GraphQL::ObjectType.define do
        name 'QueryType'
        description 'The root query for the schema'

        query_type_creator.created_api_types.each do |model, created_type|
          if created_type.fields['id']
            field model.name.underscore.to_sym do
              type created_type
              description "Find one #{model.model_name.human} by ID"
              argument :id, !types.ID
              resolve GraphQL::RootElementResolver.new(model)
            end
          end

          connection model.name.underscore.pluralize.to_sym, created_type.connection_type do
            description "Find all #{model.model_name.human.pluralize}"
            resolve GraphQL::RootCollectionResolver.new(model)
          end

        end
      end
    end

  end
end
