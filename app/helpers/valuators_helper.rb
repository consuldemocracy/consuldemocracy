module ValuatorsHelper
  def valuator_label(valuator)
    truncate([valuator.name, valuator.email, valuator.description].compact.join(" - "), length: 100)
  end

  def valuator_abilities(valuator)
    %w[can_comment can_edit_dossier]
      .select { |permission| valuator.send("#{permission}?") }
      .map    { |permission| I18n.t("admin.valuators.index.#{permission}") }
      .join(", ")
  end
end
