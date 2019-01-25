require 'rails_helper'

feature 'Remote Translations' do

  background do
    Setting["feature.remote_translations"] = true
    proposal = create(:proposal)
    microsoft_translate_client_response = ["ar", "de", "en", "es", "fa", "fr", "he", "it", "nl", "pl", "pt", "sv", "zh-Hans", "zh-Hant"]
    expect_any_instance_of(RemoteAvailableLocales).to receive(:load_remote_locales).and_return(microsoft_translate_client_response)
  end

  describe "Display remote translation button when locale is included in microsoft translate client" do

    scenario "with a locale that has :en fallback" do
      available_locales_with_fallback_en = [:ar, :de, :fa, :he, :nl, :pl, :sv]

      visit root_path(locale: available_locales_with_fallback_en.sample)

      expect(page).to have_css ".remote_translations_button"
      expect(page).to have_content "The content of this page is not available in your language"
    end

    scenario "with locale that has :es fallback" do
      available_locales_with_fallback_es = [:es, :fr, :it]

      visit root_path(locale: available_locales_with_fallback_es.sample)

      expect(page).to have_css ".remote_translations_button"
      expect(page).to have_content "El contenido de esta página no está disponible en tu idioma"
    end

    scenario "with locale that has :en fallback and need parse key" do
      available_locales_with_fallback_en = [:"zh-CN", :"zh-TW"]

      visit root_path(locale: available_locales_with_fallback_en.sample)

      expect(page).to have_css ".remote_translations_button"
      expect(page).to have_content "The content of this page is not available in your language"
    end

    scenario "with locale that has :es fallback and need parse key" do
      visit root_path(locale: :"pt-BR")

      expect(page).to have_css ".remote_translations_button"
      expect(page).to have_content "El contenido de esta página no está disponible en tu idioma"
    end

  end

  scenario "Not display remote translation button when locale is not included in microsoft translate client" do
    not_available_locales = [:en, :val, :gl, :sq]

    visit root_path(locale: not_available_locales.sample)

    expect(page).not_to have_css ".remote_translations_button"
  end

end
