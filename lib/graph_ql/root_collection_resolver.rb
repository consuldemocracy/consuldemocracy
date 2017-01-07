module GraphQL
  class RootCollectionResolver
    attr_reader :target_model

    def initialize(target_model)
      @target_model = target_model
    end

    def call(object, arguments, context)
      if target_model.respond_to?(:public_for_api)
        target_model.public_for_api
      else
        target_model.all
      end
    end
  end
end
