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
        fields.each do |field_name, field_type|
          case TypeCreator.type_kind(field_type)
          when :scalar
            field(field_name, SCALAR_TYPES[field_type])
          when :simple_association
            field(field_name, -> { type_creator.created_types[field_type] }) do
              resolve TypeCreator.create_association_resolver(field_name, field_type)
            end
          when :paginated_association
            field_type = field_type.first
            connection(field_name, -> { type_creator.created_types[field_type].connection_type }) do
              resolve TypeCreator.create_association_resolver(field_name, field_type)
            end
          end
        end

      end
      created_types[model] = created_type
      return created_type # GraphQL::ObjectType
    end

    def self.create_association_resolver(field_name, field_type)
      -> (object, arguments, context) do
        allowed_elements = target_public_elements(field_type)
        requested_elements = object.send(field_name)
        filter_forbidden_elements(requested_elements, allowed_elements, field_name)
      end
    end

    def self.target_public_elements(field_type)
      field_type.respond_to?(:public_for_api) ? field_type.public_for_api : field_type.all
    end

    def self.filter_forbidden_elements(requested, allowed_elements, field_name=nil)
      if field_name && matching_exceptions.include?(field_name)
        requested
      elsif requested.respond_to?(:each)
        requested.all & allowed_elements.all
      else
        allowed_elements.include?(requested) ? requested : nil
      end
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
