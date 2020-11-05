I18n.available_locales.each do |locale|
  next if SiteCustomization::ContentBlock.find_by(locale: locale, name: "top_links")

  I18n.with_locale(locale) do
    SiteCustomization::ContentBlock.create!(
      locale: locale,
      name: "top_links",
      body: %Q(
        <li>
          <a href="https://transparencia.santiagodecompostela.gal/portada/#{locale}">
            #{I18n.t("sites.transparency.title")}
          </a>
        </li>
        <li>
          <a href="https://datos.santiagodecompostela.gal/#{locale}">
            #{I18n.t("sites.open_data.title")}
          </a>
        </li>
      )
    )
  end
end
