module ValuationHelper

  def valuator_or_group_select_options
    valuator_group_select_options + valuator_select_options
  end

  def valuator_select_options
    Valuator.order("description ASC").order("users.email ASC").includes(:user).
             collect { |v| [ v.description_or_email, "valuator_#{v.id}"] }
  end

  def valuator_group_select_options
    ValuatorGroup.order("name ASC").collect { |g| [ g.name, "group_#{g.id}"] }
  end

  def assigned_valuators_info(valuators)
    case valuators.size
    when 0
      t("valuation.budget_investments.index.no_valuators_assigned")
    when 1
      "<span title=\"#{t('valuation.budget_investments.index.valuators_assigned', count: 1)}\">".html_safe +
        valuators.first.name +
      "</span>".html_safe
    else
      "<span title=\"".html_safe + valuators.map(&:name).join(', ') + "\">".html_safe +
        t('valuation.budget_investments.index.valuators_assigned', count: valuators.size) +
      "</span>".html_safe
    end
  end

  def explanation_field(field)
    simple_format_no_tags_no_sanitize(safe_html_with_links(field.html_safe)) if field.present?
  end

end
