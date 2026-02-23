module MlHelper
  # SUMMARIZATION & SENTIMENT
  def self.summarize_comments(comments, context = nil, config: nil)
    return nil if comments.blank?

    model_name = config&.[](:model) || Setting["llm.model"]

    system_prompt = <<~PROMPT
      You are a qualitative data analyst. Your goal is to analyze public comments and identify major recurring themes.

      Instructions:
      1. Identify 3-5 distinct Key Themes (e.g., "Safety Concerns", "Support for Green Space").
      2. For EACH theme, provide a brief explanation and select 1-2 DIRECT VERBATIM QUOTES from the text.
      3. Do not rewrite or summarize the quotes; extract them exactly as written.
      4. Provide a sentiment analysis score (percentages totaling 100).

      STRICT JSON STRUCTURE:
      {
        "executive_summary": "Overall sentiment...",
        "themes": [
          {
            "name": "Theme Name",
            "explanation": "Brief explanation",
            "quotes": ["Verbatim Quote 1", "Verbatim Quote 2"]
          }
        ],
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
  end

  #  TAGGING
  def self.generate_tags(text, count = 5, config: nil)
    return nil if text.blank?

    model_name = config&.[](:model) || Setting["llm.model"]
    system_prompt = "You are a categorization expert. Return ONLY a comma-separated list of " \
      "up to #{count} lowercase tags for the text. No intro, no bullets."

    chat = Llm::Config.context.chat(model: model_name)
    chat.with_instructions(system_prompt)
    response = chat.ask(text.truncate(2000))

    {
      "tags" => response.content.split(",").map(&:strip).compact_blank,
      "usage" => {
        "total_tokens" => (response.input_tokens || 0) + (response.output_tokens || 0)
      }
    }
  rescue => e
    Rails.logger.error "[MlHelper] Tagging Error: #{e.message}"
    nil
  end

  # 3. RELATED CONTENT
  def self.find_similar_content(source_text, candidate_texts, limit = 3, config: nil)
    return nil if source_text.blank? || candidate_texts.blank?

    model_name = config&.[](:model) || Setting["llm.model"]

    prompt = <<~PROMPT
      Identify which of the following Candidates are most conceptually related to the Source.
      Source: #{source_text}
      Candidates:
      #{candidate_texts.map.with_index { |text, i| "[#{i}] #{text}" }.join("\n")}

      Return ONLY a JSON object with the indices of the top #{limit} matches:
      { "indices": [1, 5, 2] }
    PROMPT

    perform_ai_call(prompt, model_name)
  end

  def self.perform_ai_call(prompt, model_name, system_instructions = nil)
    chat = Llm::Config.context.chat(model: model_name)
    chat.with_instructions(system_instructions) if system_instructions.present?

    response = chat.ask(prompt)
    json_match = response.content.match(/\{.*\}/m)
    return nil unless json_match

    data = JSON.parse(json_match[0])
    data["usage"] = {
      "total_tokens" => (response.input_tokens || 0) + (response.output_tokens || 0)
    }
    data
  rescue => e
    Rails.logger.error "[MlHelper] AI Call Error: #{e.message}"
    nil
  end

  private_class_method :perform_ai_call
end
