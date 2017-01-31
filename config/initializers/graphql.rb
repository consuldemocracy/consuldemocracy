api_config = YAML.load_file('./config/api.yml')

API_TYPE_DEFINITIONS = {}

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

  API_TYPE_DEFINITIONS[model] = { options: options, fields: fields }
end

# Create all GraphQL types

type_creator = GraphQL::TypeCreator.new

API_TYPE_DEFINITIONS.each do |model, info|
  type_creator.create(model, info[:fields])
end

ConsulSchema = GraphQL::Schema.define do
  query QueryRoot

  # Reject deeply-nested queries
  max_depth 10

  resolve_type -> (object, ctx) {
    # look up types by class name
    type_name = object.class.name
    ConsulSchema.types[type_name]
  }
end

QueryRoot = GraphQL::ObjectType.define do
  name "Query"
  description "The query root for this schema"

  type_creator.created_types.each do |model, created_type|

    # create an entry field to retrive a single object
    if API_TYPE_DEFINITIONS[model][:fields][:id]
      field model.name.underscore.to_sym do
        type created_type
        description "Find one #{model.model_name.human} by ID"
        argument :id, !types.ID
        resolve -> (object, arguments, context) do
          if model.respond_to?(:public_for_api)
            model.public_for_api.find(arguments["id"])
          else
            model.find(arguments["id"])
          end
        end
      end
    end

    # create an entry filed to retrive a paginated collection
    connection model.name.underscore.pluralize.to_sym, created_type.connection_type do
      description "Find all #{model.model_name.human.pluralize}"
      resolve -> (object, arguments, context) do
        if model.respond_to?(:public_for_api)
          model.public_for_api
        else
          model.all
        end
      end
    end

  end
end
