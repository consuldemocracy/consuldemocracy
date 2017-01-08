module GraphQL
  class RootElementResolver
    attr_reader :target_model

    def initialize(target_model)
      @target_model = target_model
    end

    def call(object, arguments, context)
      if target_model.respond_to?(:public_for_api)
        target_model.public_for_api.find_by(id: arguments["id"])
      else
        target_model.find_by(id: arguments["id"])
      end
    end
  end
end
