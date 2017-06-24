module InvestmentsHelper

  def investment_image_full_url(investment, version)
    URI(request.url) + investment.image.url(version)
  end

  def investment_image_file_name(investment)
    investment.image.url.split('/').last.split("?")[0] if investment.image.present?
  end

  def investment_image_advice_note_key(investment)
    investment.image.exists? ? "edit_note" : "add_note"
  end

  def investment_image_button_text_key(investment)
    investment.image.exists? ? "edit_image" : "add_image"
  end

  def errors_on_image(investment)
    @investment.errors[:image].join(', ') if @investment.errors.has_key?(:image)
  end

end