class WYSIWYGSanitizer

  ALLOWED_TAGS = %w(p ul ol li strong em u s img a h1 h2 h3 h4 h6 pre addres div)
  ALLOWED_ATTRIBUTES = %w(href style src alt)

  def sanitize(html)
    ActionController::Base.helpers.sanitize(html, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
  end

end