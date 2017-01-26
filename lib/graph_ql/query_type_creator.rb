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
            field model.graphql_field_name do
              type created_type
              description model.graphql_field_description
              argument :id, !types.ID
              resolve -> (object, arguments, context) { model.public_for_api.find_by(id: arguments['id'])}
            end
          end

          connection model.graphql_pluralized_field_name, created_type.connection_type do
            description model.graphql_pluralized_field_description
            resolve -> (object, arguments, context) { model.public_for_api }
          end

        end
      end
    end

  end
end
