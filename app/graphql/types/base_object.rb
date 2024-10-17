module Types
  class BaseObject < GraphQL::Schema::Object
    def self.field(*args, **kwargs, &)
      super

      # The old api contained non-camelized fields
      # We want to support these for now, but throw a deprecation warning
      #
      # Example:
      # proposal_notifications => Deprecation warning (Old api)
      # proposalNotifications => No deprecation warning (New api)
      field_name = args[0]

      if field_name.to_s.include?("_")
        reason = "Snake case fields are deprecated. Please use #{field_name.to_s.camelize(:lower)}."
        super(*args, **kwargs.merge({ camelize: false, deprecation_reason: reason }), &)
      end

      # Make sure associations only return public records
      # by automatically calling 'public_for_api'
      type_class = args[1]

      if type_class.is_a?(Class) && type_class.ancestors.include?(GraphQL::Types::Relay::BaseConnection)
        define_method(field_name) { object.send(field_name).public_for_api }
      end
    end

    def self.object_by_id_field(field_name, type, description, null:)
      field field_name, type, description, null: null do
        argument :id, ID, required: true, default_value: false
      end
    end

    def self.collection_field(field_name, type, ...)
      field(field_name, type.connection_type, ...)
    end
  end
end
