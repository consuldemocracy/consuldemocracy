class AdminWYSIWYGSanitizer < WYSIWYGSanitizer
  def allowed_tags
    super + %w[img]
  end

  def allowed_attributes
    super + %w[alt src style]
  end
end
