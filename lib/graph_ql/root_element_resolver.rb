module GraphQL
  class RootElementResolver
    attr_reader :target_model

    def initialize(target_model)
      @target_model = target_model
    end

    def call(object, arguments, context)
      public_elements.find_by(id: arguments['id'])
    end

    private

      def public_elements
        if target_model.respond_to?(:public_for_api)
          target_model.public_for_api
        else
          target_model
        end
      end

  end
end
