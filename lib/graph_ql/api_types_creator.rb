require 'graphql'

module GraphQL
  class ApiTypesCreator
    SCALAR_TYPES = {
      integer: GraphQL::INT_TYPE,
      boolean: GraphQL::BOOLEAN_TYPE,
      float: GraphQL::FLOAT_TYPE,
      double: GraphQL::FLOAT_TYPE,
      string: GraphQL::STRING_TYPE
    }

    attr_accessor :created_types

    def initialize(api_type_definitions)
      @api_type_definitions = api_type_definitions
      @created_types = {}
    end

    def create
      @api_type_definitions.each do |model, info|
        self.create_type(model, info[:fields])
      end
      created_types
    end

    def self.type_kind(type)
      if SCALAR_TYPES[type]
        :scalar
      elsif type.class == Class
        :singular_association
      elsif type.class == Array
        :multiple_association
      end
    end

    def create_type(model, fields)
      api_types_creator = self

      created_type = GraphQL::ObjectType.define do

        name(model.name)
        description("#{model.model_name.human}")

        # Make a field for each column, association or method
        fields.each do |field_name, field_type|
          case ApiTypesCreator.type_kind(field_type)
          when :scalar
            field(field_name, SCALAR_TYPES[field_type])
          when :singular_association
            field(field_name, -> { api_types_creator.created_types[field_type] }) do
              resolve -> (object, arguments, context) { field_type.public_for_api.find_by(id: object.id) }
            end
          when :multiple_association
            field_type = field_type.first
            connection(field_name, -> { api_types_creator.created_types[field_type].connection_type }) do
              resolve -> (object, arguments, context) { field_type.public_for_api & object.send(field_name) }
            end
          end
        end

      end
      created_types[model] = created_type
      return created_type # GraphQL::ObjectType
    end

    def self.parse_api_config_file(file)
      api_type_definitions = {}

      file.each do |api_type_model, api_type_info|
        model = api_type_model.constantize
        options = api_type_info['options']
        fields = {}

        api_type_info['fields'].each do |field_name, field_type|
          if field_type.is_a?(Array) # paginated association
            fields[field_name.to_sym] = [field_type.first.constantize]
          elsif SCALAR_TYPES[field_type.to_sym]
            fields[field_name.to_sym] = field_type.to_sym
          else # simple association
            fields[field_name.to_sym] = field_type.constantize
          end
        end

        api_type_definitions[model] = { options: options, fields: fields }
      end

      api_type_definitions
    end
  end
end
