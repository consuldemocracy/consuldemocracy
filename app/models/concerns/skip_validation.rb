module SkipValidation
  extend ActiveSupport::Concern

  module ClassMethods
    def skip_validation(field, validator)
      validator_class = if validator.is_a?(Class)
                          validator
                        else
                          "ActiveModel::Validations::#{validator.to_s.camelize}Validator".constantize
                        end

      _validators[field].reject! { |existing_validator| existing_validator.is_a?(validator_class) }

      _validate_callbacks.each do |callback|
        if callback.raw_filter.is_a?(validator_class)
          callback.raw_filter.instance_variable_set("@attributes", callback.raw_filter.attributes - [field])
        end
      end
    end

    def skip_translation_validation(field, validator)
      skip_validation(field, validator)
      translation_class.skip_validation(field, validator)
    end
  end
end
