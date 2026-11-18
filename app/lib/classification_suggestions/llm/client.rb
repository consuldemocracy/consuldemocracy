module ClassificationSuggestions
  module Llm
    class Client
      REQUEST_TIMEOUT_SECONDS = 45
      TAG_LIST_LIMIT = ResponseNormalizer::TAG_LIST_LIMIT
      MAX_SDGS = ResponseNormalizer::MAX_SDGS

      def self.call(...)
        new(...).call
      end

      def initialize(title: nil, description: nil, summary: nil,
                     selected_tags: [], selected_sdgs: [],
                     locale: I18n.locale, resource_type: "Proposal")
        @title = title
        @description = description
        @summary = summary
        @selected_tags = Array(selected_tags).map { |tag| tag.to_s.strip }.compact_blank
        @selected_sdgs = Array(selected_sdgs).map { |code| code.to_s.strip }.compact_blank.uniq
        @locale = locale
        @resource_type = resource_type
      end

      def call
        validate_llm_settings!
        return response if response.errors.any?
        return response if remaining_tag_slots.zero? && !sdg_enabled?

        suggestions = generate_suggestions
        return response if response.errors.any?

        normalized = ResponseNormalizer.new(
          suggestions,
          selected_tags: @selected_tags,
          selected_sdgs: @selected_sdgs,
          sdg_enabled: sdg_enabled?
        ).call

        response.categories = normalized[:categories]
        response.tags = normalized[:tags]
        response.sdgs = normalized[:sdgs]
      rescue StandardError => e
        Rails.logger.error("[ClassificationSuggestions] #{e.class}: #{e.message}")
        response.errors << I18n.t("classification_suggestions.errors.messages.generic")
      ensure
        return response
      end

      def response
        @response ||= Response.new
      end

      class Response
        attr_accessor :categories, :tags, :sdgs
        attr_reader :errors

        def initialize
          @categories = []
          @tags = []
          @sdgs = []
          @errors = []
        end

        def as_json(*)
          {
            categories: categories,
            tags: tags,
            sdgs: sdgs,
            errors: errors
          }
        end
      end

      private

        def validate_llm_settings!
          unless ::Llm::Config.configured? && Setting["llm.use_ai_classification_suggestions"].present?
            response.errors << I18n.t("classification_suggestions.errors.messages.llm_not_configured")
          end
        end

        def generate_suggestions
          if draft_blank?
            response.errors << I18n.t("classification_suggestions.errors.messages.blank_draft")
            return
          end

          chat.with_instructions(prompt_builder.system_instructions)

          if structured_output_supported?
            chat.with_schema(schema_payload).ask(prompt_builder.user_message).content
          else
            reply = chat.ask(prompt_builder.user_message).content
            JSON.parse(extract_json_object(reply))
          end
        end

        def llm_provider
          Setting["llm.provider"]&.downcase&.to_sym
        end

        def prompt_builder
          @prompt_builder ||= PromptBuilder.new(
            title: @title,
            summary: @summary,
            description: @description,
            locale: @locale,
            sdg_enabled: sdg_enabled?,
            max_tags: remaining_tag_slots,
            max_sdgs: remaining_sdg_slots,
            selected_tags: @selected_tags,
            selected_sdgs: @selected_sdgs
          )
        end

        def chat
          @chat ||= RubyLLM::Context.new(config_with_timeout).chat(
            provider: llm_provider,
            model: Setting["llm.model"]
          )
        end

        def config_with_timeout
          ::Llm::Config.context.config.dup.tap do |config|
            config.request_timeout = REQUEST_TIMEOUT_SECONDS
          end
        end

        def structured_output_supported?
          model = RubyLLM.models.find(Setting["llm.model"])
          model&.supports?(:structured_output)
        rescue StandardError
          false
        end

        def schema_class
          if sdg_enabled?
            ClassificationSuggestions::Schemas::WithSdgs
          else
            ClassificationSuggestions::Schemas::WithoutSdgs
          end
        end

        # Claude (via OpenRouter/Anthropic) rejects `strict` inside the JSON
        # Schema object. ruby_llm-schema 0.2.x embeds it by default; newer
        # gem versions can omit it. Strip until we upgrade.
        def schema_payload
          schema_class.new.to_json_schema.fetch(:schema).except(:strict, "strict")
        end

        def extract_json_object(content)
          raise JSON::ParserError, "blank content" if content.blank?

          match = content.match(/\{.*\}/m)
          raise JSON::ParserError, "no JSON object found" unless match

          match[0]
        end

        def draft_blank?
          @title.blank? && @summary.blank? && @description.blank?
        end

        def remaining_tag_slots
          [TAG_LIST_LIMIT - @selected_tags.size, 0].max
        end

        def remaining_sdg_slots
          [MAX_SDGS - @selected_sdgs.size, 0].max
        end

        def sdg_enabled?
          return @sdg_enabled if defined?(@sdg_enabled)

          @sdg_enabled = SDG::ProcessEnabled.new(@resource_type).enabled?
        end
    end
  end
end
