module ImageSuggestions
  module Llm
    class Client
      NUMBER_OF_IMAGES = 4
      attr_reader :model_instance, :chat, :prompt, :response

      def self.call(model_instance)
        new(model_instance).call
      end

      def initialize(model_instance)
        @model_instance = model_instance
        @prompt = load_prompt
        @response = Response.new
        @chat = build_chat
      end

      def call
        validate_llm_settings!
        return response if response.errors.any?

        search_query = generate_search_query
        return response if response.errors.any?

        results = ImageSuggestions::Pexels.search(search_query, size: :small,
                                                                per_page: NUMBER_OF_IMAGES)
        response.results = results
      rescue ::Pexels::APIError, RubyLLM::Error => e
        response.errors << e.message
      ensure
        return response
      end

      class Response
        attr_accessor :results
        attr_reader :errors

        def initialize
          @results = []
          @errors = []
        end
      end

      private

        def build_chat
          ::Llm::Config.context.chat(provider: llm_provider, model: llm_model)
        end

        def generate_search_query
          if title_text.blank? && description_text.blank?
            response.errors << I18n.t("images.errors.messages.title_and_description_required")
            return
          end

          text_prompt = prompt % { title: title_text, description: description_text }
          chat.ask(text_prompt).content.strip
        end

        def load_prompt
          YAML.load_file("config/llm_prompts.yml", aliases: true)["image_suggestion_prompt"]
        end

        def validate_llm_settings!
          if llm_provider.blank? || llm_model.blank? || !Setting["llm.use_ai_image_suggestions"]
            response.errors << I18n.t("images.errors.messages.llm_not_configured")
          end
        end

        def title_text
          model_instance.respond_to?(:title) ? model_instance.title.to_s : ""
        end

        def description_text
          model_instance.respond_to?(:description) ? model_instance.description.to_s : ""
        end

        def llm_provider
          Setting["llm.provider"]&.downcase&.to_sym
        end

        def llm_model
          Setting["llm.model"]
        end
    end
  end
end
