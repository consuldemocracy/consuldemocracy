class WYSIWYGSanitizerPresupuestos

  ALLOWED_TAGS = %w(p ul ol li strong em u s a)
  ALLOWED_ATTRIBUTES = %w(href target)

  def sanitize(html)
    ActionController::Base.helpers.sanitize(html, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
  end

end
