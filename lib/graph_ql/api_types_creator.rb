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

    def self.create(api_types_definitions)
      created_types = {}
      api_types_definitions.each do |model, info|
        create_type(model, info[:fields], created_types)
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

    def self.create_type(model, fields, created_types)

      created_types[model] = GraphQL::ObjectType.define do

        name        model.graphql_type_name
        description model.graphql_type_description

        # Make a field for each column, association or method
        fields.each do |field_name, field_type|
          case ApiTypesCreator.type_kind(field_type)
          when :scalar
            field(field_name, SCALAR_TYPES[field_type], model.human_attribute_name(field_name))
          when :singular_association
            field(field_name, -> { created_types[field_type] }) do
              resolve ->(object, arguments, context) do
                association_target = object.send(field_name)
                association_target.present? ? field_type.public_for_api.find_by(id: association_target.id) : nil
              end
            end
          when :multiple_association
            field_type = field_type.first
            connection(field_name, -> { created_types[field_type].connection_type }, max_page_size: 50, complexity: 1000) do
              resolve ->(object, arguments, context) { object.send(field_name).public_for_api }
            end
          end
        end

      end
    end

    def self.parse_api_config_file(file)
      api_type_definitions = {}

      file.each do |api_type_model, api_type_info|
        model = api_type_model.constantize
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

        api_type_definitions[model] = { fields: fields }
      end

      api_type_definitions
    end
  end
end
