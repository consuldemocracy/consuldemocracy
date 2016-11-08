class ExposableField
  attr_reader :name, :graphql_type

  def initialize(column, options = {})
    @name = column.name
    @graphql_type = ExposableField.convert_type(column.type)
  end

  private

  # Return a GraphQL type for 'database_type'
  def self.convert_type(database_type)
    case database_type
    when :integer
      GraphQL::INT_TYPE
    when :boolean
      GraphQL::BOOLEAN_TYPE
    when :float
      GraphQL::FLOAT_TYPE
    when :double
      GraphQL::FLOAT_TYPE
    else
      GraphQL::STRING_TYPE
    end
  end
end
