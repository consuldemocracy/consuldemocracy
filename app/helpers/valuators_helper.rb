module ValuatorsHelper

  def valuator_label(valuator)
    truncate([valuator.name, valuator.email, valuator.description].compact.join(" - "), length: 100)
  end

  def valuator_abilities(valuator)
    [ valuator.can_comment ? I18n.t("admin.valuators.index.can_comment") : nil ,
      valuator.can_edit_dossier ? I18n.t("admin.valuators.index.can_edit_dossier") : nil
    ].compact.join(", ")
  end
end
