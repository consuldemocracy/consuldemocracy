api_config = YAML.load_file('./config/api.yml')

api_type_definitions = {}

# Parse API configuration file

api_config.each do |api_type_model, api_type_info|
  model = api_type_model.constantize
  options = api_type_info['options']
  fields = {}

  api_type_info['fields'].each do |field_name, field_type|
    if field_type.is_a?(Array) # paginated association
      fields[field_name.to_sym] = [field_type.first.constantize]
    elsif GraphQL::TypeCreator::SCALAR_TYPES[field_type.to_sym]
      fields[field_name.to_sym] = field_type.to_sym
    else # simple association
      fields[field_name.to_sym] = field_type.constantize
    end
  end

  api_type_definitions[model] = { options: options, fields: fields }
end

type_creator = GraphQL::TypeCreator.new(api_type_definitions)
QueryType = type_creator.query_type

ConsulSchema = GraphQL::Schema.define do
  query QueryType
  max_depth 10

  resolve_type -> (object, ctx) do
    type_name = object.class.name # look up types by class name
    ConsulSchema.types[type_name]
  end
end
