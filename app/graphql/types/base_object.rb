module Types
  class BaseObject < GraphQL::Schema::Object
    def self.field(*args, **kwargs, &)
      super(*args, **kwargs, &)

      # The old api contained non-camelized fields
      # We want to support these for now, but throw a deprecation warning
      #
      # Example:
      # proposal_notifications => Deprecation warning (Old api)
      # proposalNotifications => No deprecation warning (New api)
      field_name = args[0]

      if field_name.to_s.include?("_")
        reason = "Snake case fields are deprecated. Please use #{field_name.to_s.camelize(:lower)}."
        kwargs = kwargs.merge({ camelize: false, deprecation_reason: reason })
        super(*args, **kwargs, &)
      end

      # Make sure associations only return public records
      # by automatically calling 'public_for_api'
      type_class = args[1]

      if type_class.is_a?(Class) && type_class.ancestors.include?(GraphQL::Types::Relay::BaseConnection)
        define_method(field_name) { object.send(field_name).public_for_api }
      end
    end
  end
end
