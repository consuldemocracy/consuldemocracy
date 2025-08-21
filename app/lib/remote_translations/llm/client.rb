module RemoteTranslations
  module Llm
    class Client
      attr_reader :context, :chat, :prompt

      TOKENS_PER_WORD = 3 # approximation

      class LLMTranslationError < StandardError; end

      def initialize
        @context = Config.context
        @chat = @context.chat(provider: Setting["llm.provider"].downcase.to_sym, model: Setting["llm.model"])
        @prompt = YAML.load_file("config/llm_prompts.yml", aliases: true)["remote_translation_prompt"]
      end

      def call(fields_values, locale)
        fields_values.map do |text|
          request_translation(text, locale)
        end
      end

      private

        def request_translation(text, locale)
          text_placeholders = {
            input_text: text,
            output_locale: locale
          }
          text_prompt = prompt % text_placeholders

          if text_prompt.size * TOKENS_PER_WORD < RubyLLM.models.find(Setting["llm.model"]).context_window
            chat.ask(text_prompt).content
          else
            raise LLMTranslationError, "Text to translate is too long for the model context window"
          end
        end
    end
  end
end
