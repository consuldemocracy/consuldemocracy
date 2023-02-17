require "rails_helper"

describe Layout::RemoteTranslationsButtonComponent do
  let(:translations) { [RemoteTranslation.new] }
  let(:component) { Layout::RemoteTranslationsButtonComponent.new(translations) }

  before do
    allow(RemoteTranslations::Microsoft::AvailableLocales).to receive(:available_locales)
                                                          .and_return(%w[de en es fr pt zh-Hans])
  end

  context "locale with English as a fallback" do
    before do
      allow(I18n.fallbacks).to receive(:[]).and_return([:en])
      Globalize.set_fallbacks_to_all_available_locales
    end

    it "displays the text in English" do
      I18n.with_locale(:de) { render_inline component }

      expect(page).to have_css ".remote-translations-button"
      expect(page).to have_content "The content of this page is not available in your language"
    end

    it "displays the text in English with a locale needing parsing" do
      I18n.with_locale(:"zh-CN") { render_inline component }

      expect(page).to have_css ".remote-translations-button"
      expect(page).to have_content "The content of this page is not available in your language"
    end
  end

  context "locale with Spanish as a fallback" do
    before do
      allow(I18n.fallbacks).to receive(:[]).and_return([:es])
      Globalize.set_fallbacks_to_all_available_locales
    end

    it "displays the text in Spanish" do
      I18n.with_locale(:fr) { render_inline component }

      expect(page).to have_css ".remote-translations-button"
      expect(page).to have_content "El contenido de esta página no está disponible en tu idioma"
    end

    it "displays the text in Spanish with a locale needing parsing" do
      I18n.with_locale(:"pt-BR") { render_inline component }

      expect(page).to have_css ".remote-translations-button"
      expect(page).to have_content "El contenido de esta página no está disponible en tu idioma"
    end
  end

  it "is not rendered when the locale isn't included in microsoft translate client" do
    I18n.with_locale(:nl) { render_inline component }

    expect(page).not_to be_rendered
  end

  it "is not rendered when there aren't any remote translations" do
    render_inline Layout::RemoteTranslationsButtonComponent.new([])

    expect(page).not_to be_rendered
  end
end
