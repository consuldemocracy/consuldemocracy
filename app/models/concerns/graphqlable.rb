module Graphqlable
  extend ActiveSupport::Concern

  class_methods do

    def graphql_field_name
      self.name.gsub('::', '_').underscore.to_sym
    end

    def graphql_field_description
      "Find one #{self.model_name.human} by ID"
    end

    def graphql_pluralized_field_name
      self.name.gsub('::', '_').underscore.pluralize.to_sym
    end

    def graphql_pluralized_field_description
      "Find all #{self.model_name.human.pluralize}"
    end

    def graphql_type_name
      self.name.gsub('::', '_')
    end

    def graphql_type_description
      "#{self.model_name.human}"
    end

  end

  def public_created_at
    self.created_at.change(min: 0)
  end

end
