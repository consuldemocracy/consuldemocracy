module LocalesHelper

  def name_for_locale(locale)
    default = I18n.t("locale", locale: locale)
    I18n.backend.translate(locale, "i18n.language.name", default: default)
  rescue
    nil
  end

end
