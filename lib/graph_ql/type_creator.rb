module GraphQL
  class TypeCreator

    # Return a GraphQL type for a 'database_type'
    TYPES_CONVERSION = Hash.new(GraphQL::STRING_TYPE).merge(
      integer: GraphQL::INT_TYPE,
      boolean: GraphQL::BOOLEAN_TYPE,
      float: GraphQL::FLOAT_TYPE,
      double: GraphQL::FLOAT_TYPE
    )

    def self.create(model, field_names, api_types)

      new_graphql_type = GraphQL::ObjectType.define do

        name(model.name)
        description("#{model.model_name.human}")

        # Make a field for each column
        field_names.each do |field_name|
          if model.column_names.include?(field_name.to_s)
            field(field_name.to_s, TYPES_CONVERSION[field_name])
          else
            association = model.reflect_on_all_associations.find { |a| a.name == field_name }
            case association.macro
            when :has_one
              field(association.name, -> { api_types[association.klass] })
            when :belongs_to
              field(association.name, -> { api_types[association.klass] })
            when :has_many
              connection(association.name, api_types[association.klass].connection_type {
                description "#{association.klass.model_name.human.pluralize}"
                resolve -> (object, arguments, context) {
                  association.klass.all
                }
              })
            end
          end
        end
      end

      return new_graphql_type
    end
  end
end
