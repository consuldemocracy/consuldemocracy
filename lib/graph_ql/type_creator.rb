module GraphQL
  class TypeCreator
    # Return a GraphQL type for a 'database_type'
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
        fields.each do |name, type|
          case GraphQL::TypeCreator.type_kind(type)
          when :scalar
            field name, SCALAR_TYPES[type]
          when :simple_association
            field(name, -> { type_creator.created_types[type] }) do
              resolve -> (object, arguments, context) do
                target_public_elements = type.respond_to?(:public_for_api) ? type.public_for_api : type.all
                wanted_element = object.send(name)
                if target_public_elements.include?(wanted_element) || GraphQL::TypeCreator.matching_exceptions.include?(name)
                  wanted_element
                else
                  nil
                end
              end
            end
          when :paginated_association
            type = type.first
            connection(name, -> { type_creator.created_types[type].connection_type }) do
              resolve -> (object, arguments, context) do
                target_public_elements = type.respond_to?(:public_for_api) ? type.public_for_api : type.all
                object.send(name).all & target_public_elements.all
              end
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

    # TODO: esto es una ñapa, hay que buscar una solución mejor
    def self.matching_exceptions
      [:public_voter]
    end

  end
end
