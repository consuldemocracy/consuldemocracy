require "rails_helper"

describe "Remote Translations" do
  before do
    Setting["feature.remote_translations"] = true
    create(:proposal)
    available_locales_response = %w[de en es fr pt zh-Hans]
    expect(RemoteTranslations::Microsoft::AvailableLocales).to receive(:available_locales).at_most(2).times.
                                                            and_return(available_locales_response)
    allow(Rails.application.secrets).to receive(:microsoft_api_key).and_return("123")
  end

  describe "Display remote translation button when locale is included in microsoft translate client" do
    context "with locale that has :en fallback" do
      before do
        allow(I18n.fallbacks).to receive(:[]).and_return([:en])
        Globalize.set_fallbacks_to_all_available_locales
      end

      scenario "should display text in English" do
        visit root_path(locale: :de)

        expect(page).to have_css ".remote-translations-button"
        expect(page).to have_content "The content of this page is not available in your language"
      end

      scenario "should display text in English after parse key" do
        visit root_path(locale: :"zh-CN")

        expect(page).to have_css ".remote-translations-button"
        expect(page).to have_content "The content of this page is not available in your language"
      end
    end

    context "with locale that has :es fallback" do
      before do
        allow(I18n.fallbacks).to receive(:[]).and_return([:es])
        Globalize.set_fallbacks_to_all_available_locales
      end

      scenario "should display text in Spanish" do
        visit root_path(locale: :fr)

        expect(page).to have_css ".remote-translations-button"
        expect(page).to have_content "El contenido de esta página no está disponible en tu idioma"
      end

      scenario "should display text in Spanish after parse key" do
        visit root_path(locale: :"pt-BR")

        expect(page).to have_css ".remote-translations-button"
        expect(page).to have_content "El contenido de esta página no está disponible en tu idioma"
      end
    end
  end

  scenario "Not display remote translation button when locale is not included in microsoft translate client" do
    visit root_path(locale: :nl)

    expect(page).not_to have_css ".remote-translations-button"
  end
end
