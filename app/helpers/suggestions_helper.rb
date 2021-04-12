module SuggestionsHelper
  def suggest_data(record)
    return unless record.new_record?

    {
      js_suggest_result: "js_suggest_result",
      js_suggest: ".js-suggest",
      js_url: polymorphic_path(record.class, action: :suggest)
    }
  end
end
