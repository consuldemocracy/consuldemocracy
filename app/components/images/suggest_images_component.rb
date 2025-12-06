module Images
  class SuggestImagesComponent < ApplicationComponent
    attr_reader :f

    def initialize(f)
      @f = f
    end

    def render?
      [Setting["llm.provider"], Setting["llm.model"],
       Setting["llm.use_ai_image_suggestions"]].all?(&:present?)
    end

    private

      def resource_type
        f.object.class.name
      end

      def resource_id
        f.object.id if f.object.persisted?
      end
  end
end
