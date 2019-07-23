require "rails_helper"

describe "Remote Translations" do

  before do
    Setting["feature.remote_translations"] = true
    create(:proposal)
    available_locales_response = ["ar", "de", "en", "es", "fa", "fr", "he", "it", "nl", "pl",
                                  "pt", "sv", "zh-Hans", "zh-Hant"]
    expect(RemoteTranslations::Microsoft::AvailableLocales).to receive(:available_locales).
                                                            and_return(available_locales_response)
  end

  after do
    allow(I18n).to receive(:available_locales).and_call_original
    allow(I18n.fallbacks).to receive(:[]).and_call_original
    Globalize.set_fallbacks_to_all_available_locales
  end

  describe "Display remote translation button when locale is included in microsoft translate client" do

    context "with locale that has :en fallback" do

      before do
        allow(I18n.fallbacks).to receive(:[]).and_return([:en])
        Globalize.set_fallbacks_to_all_available_locales
      end

      scenario "should display text in English" do
        available_locales_with_fallback_en = [:ar, :de, :fa, :he, :nl, :pl, :sv]

        visit root_path(locale: available_locales_with_fallback_en.sample)

        expect(page).to have_css ".remote-translations-button"
        expect(page).to have_content "The content of this page is not available in your language"
      end

      scenario "should display text in English after parse key" do
        available_locales_with_fallback_en = [:"zh-CN", :"zh-TW"]

        visit root_path(locale: available_locales_with_fallback_en.sample)

        expect(page).to have_css ".remote-translations-button"
        expect(page).to have_content "The content of this page is not available in your language"
      end
    end

    context "with locale that has :en fallback" do

      before do
        allow(I18n.fallbacks).to receive(:[]).and_return([:es])
        Globalize.set_fallbacks_to_all_available_locales
      end

      scenario "with locale that has :es fallback" do
        available_locales_with_fallback_es = [:es, :fr, :it]

        visit root_path(locale: available_locales_with_fallback_es.sample)

        expect(page).to have_css ".remote-translations-button"
        expect(page).to have_content "El contenido de esta página no está disponible en tu idioma"
      end

      scenario "with locale that has :es fallback and need parse key" do
        visit root_path(locale: :"pt-BR")

        expect(page).to have_css ".remote-translations-button"
        expect(page).to have_content "El contenido de esta página no está disponible en tu idioma"
      end
    end

  end

  scenario "Not display remote translation button when locale is not included in microsoft translate client" do
    not_available_locales = [:val, :gl, :sq]

    visit root_path(locale: not_available_locales.sample)

    expect(page).not_to have_css ".remote-translations-button"
  end

end
