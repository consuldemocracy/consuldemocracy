# frozen_string_literal: true

module AiModeratable
  extend ActiveSupport::Concern

  included do
    after_commit :queue_ai_moderation, on: :create
  end

  def queue_ai_moderation
    delay.moderate_with_ai
  end

  def moderate_with_ai
    return if body.blank?
    return unless defined?(RubyLLM)

    model_name = Setting["llm.model"]
    provider_name = Setting["llm.provider"].to_s.downcase.to_sym
    return if model_name.blank? || provider_name.blank?

    return unless Setting.find_by(key: "llm.comment_moderation")&.enabled?

    # Define thresholds. Fall back to global defaults if settings don't exist.
    flag_threshold   = (Setting["llm.moderation_flag_threshold"] || 0.4).to_f
    hidden_threshold = (Setting["llm.moderation_hidden_threshold"] || 0.75).to_f

    system_prompt = <<~PROMPT
      You are an advanced automated content moderation system.
      Analyze the input comment and provide a floating-point score between 0.0 and 1.0 for each category.

      Categories:
      - hate_speech: Discriminatory language targeting protected groups, racism, sexism, bigotry.
      - harassment: Targeted attacks, bullying, cyberstalking, or persistent personal insults.
      - violence: Threats of physical harm, glorification of self-harm, or terrorist incitement.
      - sexual: Explicit or graphic adult content.
      - profanity_insults: General vulgarity, swearing, coarse language, or casual insults.

      STRICT JSON STRUCTURE RESPONSES ONLY. DO NOT INCLUDE ANY OUTSIDE TEXT OR MARKDOWN FENCES:
      {
        "categories": {
          "hate_speech": 0.05,
          "harassment": 0.12,
          "violence": 0.00,
          "sexual": 0.00,
          "profanity_insults": 0.45
        },
        "reasoning": "Brief operational justification for the scores."
      }
    PROMPT

    begin
      active_context = Llm::Config.context
      chat_params = { model: model_name, provider: provider_name }

      # Sync with your provider configurations
      if provider_name == :ollama
        chat_params[:assume_model_exists] = true
        active_context = active_context.dup { |c| c.request_timeout = 300 }
      elsif provider_name == :vertexai
        active_context = active_context.dup do |c|
          loc_secret = Tenant.current_secrets.llm&.[]("vertexai_location")
          c.vertexai_location = loc_secret || "us-central1"
        end
      elsif provider_name == :anthropic || model_name.include?("claude")
        active_context = active_context.dup { |c| c.retry_interval = 12.0 }
      end

      chat = active_context.chat(**chat_params)
      chat.with_instructions(system_prompt)
      response = chat.ask(body.truncate(2000))

      raw_content = response.nil? || response.content.nil? ? nil : response.content
      raw_content = raw_content.text unless raw_content.is_a?(String)
      return if raw_content.blank?

      json_match = raw_content.match(/\{.*}/m)
      return if json_match.blank?

      data = JSON.parse(json_match[0])
      scores = data["categories"] || {}

      # --- AGGREGATION & THRESHOLD CHECKING LOGIC ---
      is_flagged = false
      is_hidden = false
      triggered_categories = []

      scores.each do |category, score|
        score_value = score.to_f

        # High severity violation triggers automatic hiding
        if score_value >= hidden_threshold
          is_hidden = true
          is_flagged = true
          triggered_categories << "#{category}(H:#{score_value})"
          # Moderate violation triggers a flag for review
        elsif score_value >= flag_threshold
          is_flagged = true
          triggered_categories << "#{category}(F:#{score_value})"
        end
      end

      # --- CALCULATE FLAGS IF TRIGGERED ---
      calculated_flags = 0
      if is_flagged || is_hidden
        scores.each do |_, val|
          v = val.to_f
          calculated_flags += 4 if v >= hidden_threshold
          calculated_flags += 2 if v >= flag_threshold && v < hidden_threshold
        end
      else
        calculated_flags = flags_count
      end

      meta_payload = {
        model_used: model_name,
        evaluated_at: Time.current,
        scores: scores,
        reasoning: data["reasoning"],
        flagged: is_flagged,
        hidden: is_hidden
      }

      update_columns(
        flags_count: calculated_flags,
        hidden_at: is_hidden ? Time.current : hidden_at,
        ai_moderation_meta: meta_payload
      )

      if is_flagged || is_hidden
        log_msg = I18n.t(
          "moderation.ai_integration.logs.flagged_or_hidden",
          id: id,
          model: model_name,
          triggers: triggered_categories.join(", "),
          reason: data["reasoning"]
        )
      else
        log_msg = I18n.t("moderation.ai_integration.logs.clean", id: id, model: model_name)
      end

      Rails.logger.info log_msg

    rescue RubyLLM::Error => e
      err_msg = I18n.t("moderation.ai_integration.errors.ruby_llm_crash", id: id, message: e.message)
      Rails.logger.error err_msg
      raise e
    rescue JSON::ParserError
      log_warn = I18n.t("moderation.ai_integration.errors.json_parser_crash", id: id, content: raw_content.inspect)
      Rails.logger.warn log_warn
    rescue => e
      err_msg = I18n.t("moderation.ai_integration.errors.unexpected_exception", id: id, message: e.message)
      Rails.logger.error err_msg
    end
  end
end
