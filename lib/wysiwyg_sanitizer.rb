class WYSIWYGSanitizer

  ALLOWED_TAGS = %w(p ul ol li strong em u s img a h2 h3)
  ALLOWED_ATTRIBUTES = %w(href style src alt)

  def sanitize(html)
    ActionController::Base.helpers.sanitize(html, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
  end

end