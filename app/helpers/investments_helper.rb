module InvestmentsHelper

  def investment_image_full_url(investment, version)
    URI(request.url) + investment.image_url(version)
  end

  def investment_image_advice_note(investment)
    if investment.image.present?
      t("budgets.investments.edit_image.edit_note", title: investment.title)
    else
      t("budgets.investments.edit_image.add_note", title: investment.title)
    end
  end

  def investment_image_button_text(investment)
    investment.image.present? ? t("budgets.investments.show.edit_image") : t("budgets.investments.show.add_image")
  end

  def errors_on_image(investment)
    investment.errors[:attachment].join(', ') if investment.errors.key?(:attachment)
  end

end
