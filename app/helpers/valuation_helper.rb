module ValuationHelper
  def explanation_field(field)
    simple_format_no_tags_no_sanitize(sanitize_and_auto_link(field)) if field.present?
  end
end
