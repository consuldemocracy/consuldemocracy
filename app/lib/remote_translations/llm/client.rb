module RemoteTranslations
  module Llm
    class Client
      attr_reader :context, :chat, :prompt

      def initialize
        @context = build_context
        @chat = build_chat
        @prompt = load_prompt
      end

      def call(fields_values, locale)
        fields_values.map do |text|
          request_translation(text, locale)
        end
      end

      private

        def build_context
          ::Llm::Config.context
        end

        def build_chat
          build_context.chat(provider: Setting["llm.provider"].downcase.to_sym, model: Setting["llm.model"])
        end

        def load_prompt
          YAML.load_file("config/llm_prompts.yml", aliases: true)["remote_translation_prompt"]
        end

        def request_translation(text, locale)
          text_prompt = prompt % { input_text: text, output_locale: locale }
          chat.ask(text_prompt).content
        end
    end
  end
end
