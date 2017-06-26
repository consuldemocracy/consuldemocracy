module InvestmentsHelper

  def investment_image_full_url(investment, version)
    URI(request.url) + investment.image.url(version)
  end

  def investment_image_file_name(investment)
    investment.image.url.split('/').last.split("?")[0] if investment.image.present?
  end

  def investment_image_advice_note(investment)
    title = investment.title
    if investment.image.exists?
      t "budgets.investments.edit_image.edit_note", title: title
    else
      t "budgets.investments.edit_image.add_note", title: title
    end
  end

  def investment_image_button_text(investment)
    if investment.image.exists?
      t "budgets.investments.show.edit_image"
    else
      t "budgets.investments.show.add_image"
    end
  end

  def errors_on_image(investment)
    investment.errors[:image].join(', ') if investment.errors.has_key?(:image)
  end

end