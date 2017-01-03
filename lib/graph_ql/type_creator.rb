module GraphQL
  class TypeCreator
    SCALAR_TYPES = {
      integer: GraphQL::INT_TYPE,
      boolean: GraphQL::BOOLEAN_TYPE,
      float: GraphQL::FLOAT_TYPE,
      double: GraphQL::FLOAT_TYPE,
      string: GraphQL::STRING_TYPE
    }

    attr_accessor :created_types

    def initialize
      @created_types = {}
    end

    def create(model, fields)
      type_creator = self

      created_type = GraphQL::ObjectType.define do

        name(model.name)
        description("#{model.model_name.human}")

        # Make a field for each column, association or method
        fields.each do |field_name, field_type|
          case TypeCreator.type_kind(field_type)
          when :scalar
            field(field_name, SCALAR_TYPES[field_type])
          when :simple_association
            field(field_name, -> { type_creator.created_types[field_type] }) do
              resolve GraphQL::AssociationResolver.new(field_name, field_type)
            end
          when :paginated_association
            field_type = field_type.first
            connection(field_name, -> { type_creator.created_types[field_type].connection_type }) do
              resolve GraphQL::AssociationResolver.new(field_name, field_type)
            end
          end
        end

      end
      created_types[model] = created_type
      return created_type # GraphQL::ObjectType
    end

    def self.type_kind(type)
      if SCALAR_TYPES[type]
        :scalar
      elsif type.class == Class
        :simple_association
      elsif type.class == Array
        :paginated_association
      end
    end

  end
end
