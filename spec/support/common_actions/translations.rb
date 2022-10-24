module Translations
  def text_for(field, locale)
    I18n.with_locale(locale) do
      "#{translatable.class.human_attribute_name(field)} #{language_texts[locale]}"
    end
  end

  def expect_not_to_have_language(language)
    expect(page).not_to have_select :select_language, with_options: [language]
  end

  def expect_to_have_language_selected(language)
    expect(page).to have_select :select_language, selected: language
  end

  def language_texts
    {
      es: "en español",
      en: "in English"
    }
  end
end
