module GraphQL
  class AssociationResolver
    attr_reader :field_name, :target_model, :allowed_elements

    def initialize(field_name, target_model)
      @field_name = field_name
      @target_model = target_model
      @allowed_elements = target_public_elements
    end

    def call(object, arguments, context)
      requested_elements = object.send(field_name)
      filter_forbidden_elements(requested_elements)
    end

    private

      def target_public_elements
        target_model.respond_to?(:public_for_api) ? target_model.public_for_api : target_model.all
      end

      def filter_forbidden_elements(requested_elements)
        if requested_elements.respond_to?(:each)
          requested_elements.all & allowed_elements.all
        else
          allowed_elements.include?(requested_elements) ? requested_elements : nil
        end
      end
  end
end
