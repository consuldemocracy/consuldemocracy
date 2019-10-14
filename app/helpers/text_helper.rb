module TextHelper
  def first_paragraph(text)
    if text.blank?
      ""
    else
      text.strip.split("\n").first
    end
  end
end
