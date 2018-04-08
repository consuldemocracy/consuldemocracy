module Graphqlable
  extend ActiveSupport::Concern

  class_methods do

    def graphql_field_name
      name.gsub('::', '_').underscore.to_sym
    end

    def graphql_field_description
      "Find one #{model_name.human} by ID"
    end

    def graphql_pluralized_field_name
      name.gsub('::', '_').underscore.pluralize.to_sym
    end

    def graphql_pluralized_field_description
      "Find all #{model_name.human.pluralize}"
    end

    def graphql_type_name
      name.gsub('::', '_')
    end

    def graphql_type_description
      model_name.human.to_s
    end

  end

  def public_created_at
    created_at.change(min: 0)
  end

end
