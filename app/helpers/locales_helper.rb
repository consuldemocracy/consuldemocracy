module LocalesHelper

  def name_for_locale(locale)
    I18n.t("i18n.language.name", locale: locale, fallback: false, default: locale.to_s)
  end

end
