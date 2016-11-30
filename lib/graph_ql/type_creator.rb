module GraphQL
  class TypeCreator
    # Return a GraphQL type for a 'database_type'
    TYPES_CONVERSION = Hash.new(GraphQL::STRING_TYPE).merge(
      integer: GraphQL::INT_TYPE,
      boolean: GraphQL::BOOLEAN_TYPE,
      float: GraphQL::FLOAT_TYPE,
      double: GraphQL::FLOAT_TYPE
    )

    attr_accessor :created_types

    def initialize
      @created_types = {}
    end

    def create(model, field_names)
      type_creator = self

      created_type = GraphQL::ObjectType.define do

        name(model.name)
        description("#{model.model_name.human}")

        # Make a field for each column
        field_names.each do |field_name|
          if model.column_names.include?(field_name.to_s)
            field(field_name.to_s, TYPES_CONVERSION[model.columns_hash[field_name.to_s].type])
          else
            association = model.reflect_on_all_associations.find { |a| a.name == field_name }
            case association.macro
            when :has_one
              field(association.name, -> { type_creator.created_types[association.klass] })
            when :belongs_to
              field(association.name, -> { type_creator.created_types[association.klass] })
            when :has_many
              connection association.name, -> do
                type_creator.created_types[association.klass].connection_type do
                  description "#{association.klass.model_name.human.pluralize}"
                  resolve -> (object, arguments, context) { association.klass.all }
                end
              end
            end
          end
        end
      end
      created_types[model] = created_type
      return created_type # GraphQL::ObjectType
    end
  end
end
