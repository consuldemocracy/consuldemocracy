module ValuationHelper

  def valuator_select_options(valuator=nil)
    if valuator.present?
      Valuator.where.not(id: valuator.id).order('users.username asc').includes(:user).collect { |v| [ v.name, v.id ] }.prepend([valuator.name, valuator.id])
    else
      Valuator.all.order('users.username asc').includes(:user).collect { |v| [ v.name, v.id ] }
    end
  end

  def assigned_valuators_info(valuators)
    case valuators.size
    when 0
      t("valuation.spending_proposals.index.no_valuators_assigned")
    when 1
      "<span title=\"#{t('valuation.spending_proposals.index.valuators_assigned', count: 1)}\">".html_safe +
        valuators.first.name +
      "</span>".html_safe
    else
      "<span title=\"".html_safe + valuators.map(&:name).join(', ') + "\">".html_safe +
        t('valuation.spending_proposals.index.valuators_assigned', count: valuators.size) +
      "</span>".html_safe
    end
  end

  def explanation_field(field)
    simple_format_no_tags_no_sanitize(safe_html_with_links(field.html_safe)) if field.present?
  end

end