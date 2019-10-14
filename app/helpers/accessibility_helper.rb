module AccessibilityHelper

  def css_for_aria_hidden(reason)
    reason.present? ? "true" : ""
  end

end
