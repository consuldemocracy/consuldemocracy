class AdminWYSIWYGSanitizer < WYSIWYGSanitizer
  def allowed_tags
    super + %w[img div code table caption thead tbody tr th td span]
  end

  def allowed_attributes
    super + %w[alt src style class scope id]
  end
end
