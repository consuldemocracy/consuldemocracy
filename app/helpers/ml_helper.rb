module MlHelper
  # SUMMARIZATION & SENTIMENT
  def self.summarize_comments(comments, context = nil, config: nil)
    return nil if comments.blank?

    model_name = config&.[](:model) || Setting["llm.model"]

    system_prompt = <<~PROMPT
      You are a qualitative data analyst. Your goal is to analyze public comments and identify major recurring themes.
      Instructions:
      1. Identify 3-5 distinct Key Themes.
      2. For EACH theme, provide a brief explanation and select 1-2 DIRECT VERBATIM QUOTES.
      3. Provide a sentiment analysis score (percentages totaling 100).
      STRICT JSON STRUCTURE:
      {
        "executive_summary": "Overall sentiment...",
        "themes": [{"name": "Theme Name", "explanation": "Brief explanation", "quotes": ["Quote 1"]}],
        "sentiment": {"positive": 50, "negative": 20, "neutral": 30}
      }
    PROMPT

    input_text = "CONTEXT: #{context}\n\nCOMMENTS:\n#{comments.join("\n").truncate(6000)}"
    data = perform_ai_call(input_text, model_name, system_prompt)
    return nil if data.blank?

    markdown = "**Executive Summary**: #{data["executive_summary"]}\n\n**Key Themes & Voices**:\n"
    (data["themes"] || []).each do |t|
      name = t["name"] || t["title"]
      next if name.blank?

      markdown += "* **#{name}**: #{t["explanation"]}\n"
      t["quotes"]&.each { |q| markdown += "  > \"#{q}\"\n" }
      markdown += "\n"
    end

    {
      "summary_markdown" => markdown.strip,
      "sentiment" => data["sentiment"] || { "positive" => 0, "negative" => 0, "neutral" => 100 },
      "usage" => data["usage"]
    }
  rescue RubyLLM::Error => e
    Rails.logger.error "[MlHelper] Summarization failed: #{e.message}"
    raise e
  end

  def self.generate_tags(text, count = 5, config: nil)
    return nil if text.blank?

    model_name = config&.[](:model) || Setting["llm.model"]
    provider_name = Setting["llm.provider"].to_s.downcase.to_sym
    system_prompt = "Return ONLY a comma-separated list of up to #{count} " \
                    "lowercase single-word tags. No introduction or sentences."

    # Use specialized context for Ollama (Bypass + Timeout)
    active_context = Llm::Config.context
    chat_params = { model: model_name }

    if provider_name == :ollama
      chat_params[:assume_model_exists] = true
      chat_params[:provider] = :ollama
      active_context = active_context.dup { |c| c.request_timeout = 300 }
    end

    chat = active_context.chat(**chat_params)
    chat.with_instructions(system_prompt)
    response = chat.ask(text.truncate(2000))

    raw_content = extract_text_content(response)
    return nil if raw_content.blank?

    clean_content = ActionController::Base.helpers.strip_tags(raw_content)

    tags = clean_content.split(",")
                        .map(&:strip)
                        .map { |t| t.gsub(/[^\w\s-]/, "") }
                        .map { |t| t.truncate(150) }
                        .compact_blank

    {
      "tags" => tags.first(count),
      "usage" => {
        "total_tokens" => (response.respond_to?(:input_tokens) ? (response.input_tokens || 0) : 0) +
          (response.respond_to?(:output_tokens) ? (response.output_tokens || 0) : 0)
      }
    }
  rescue RubyLLM::Error => e
    Rails.logger.error "[MlHelper] Tagging failed: #{e.message}"
    raise e
  end

  # RELATED CONTENT (Unchanged structure, uses perform_ai_call)
  def self.find_similar_content(source_text, candidate_texts, limit = 3, config: nil)
    return nil if source_text.blank? || candidate_texts.blank?

    model_name = config&.[](:model) || Setting["llm.model"]
    prompt = <<~PROMPT
      Identify which of the following Candidates are most conceptually related to the Source.
      Source: #{source_text}
      Candidates: #{candidate_texts.map.with_index { |text, i| "[#{i}] #{text}" }.join("\n")}
      Return ONLY a JSON object with the indices of the top #{limit} matches: { "indices": [1, 5, 2] }
    PROMPT
    perform_ai_call(prompt, model_name)
  end

  def self.perform_ai_call(prompt, model_name, system_instructions = nil)
    provider_name = Setting["llm.provider"].to_s.downcase.to_sym
    active_context = Llm::Config.context
    chat_params = { model: model_name }

    if provider_name == :ollama
      chat_params[:assume_model_exists] = true
      chat_params[:provider] = :ollama
      # Override for local hardware: High timeout, but shorter retry interval than Claude
      active_context = active_context.dup do |c|
        c.request_timeout = 300
        c.retry_interval = 2.0 # Locally, 2s is enough; 12s is overkill
      end
    elsif provider_name == :anthropic || model_name.include?("claude")
      # Keep the logic specifically for Claude quota/rate limits
      active_context = active_context.dup do |c|
        c.retry_interval = 12.0
      end
    end

    chat = active_context.chat(**chat_params)
    chat.with_instructions(system_instructions) if system_instructions.present?

    response = chat.ask(prompt)
    content = extract_text_content(response)
    return nil if content.blank?

    json_match = content.match(/\{.*}/m)
    return nil unless json_match

    begin
      data = JSON.parse(json_match[0])
      input_tokens = response.respond_to?(:input_tokens) ? (response.input_tokens || 0) : 0
      output_tokens = response.respond_to?(:output_tokens) ? (response.output_tokens || 0) : 0

      data["usage"] = {
        "total_tokens" => input_tokens + output_tokens
      }
      data
    rescue JSON::ParserError
      nil
    end
  rescue RubyLLM::Error => e
    Rails.logger.error "[MlHelper] AI call failed: #{e.message}"
    raise e
  end

  def self.extract_text_content(response)
    return nil if response.nil? || response.content.nil?

    response.content.is_a?(String) ? response.content : response.content.text
  end

  private_class_method :perform_ai_call, :extract_text_content
end
