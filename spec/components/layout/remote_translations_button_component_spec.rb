require "rails_helper"

describe Layout::RemoteTranslationsButtonComponent do
  let(:component) { Layout::RemoteTranslationsButtonComponent.new(records) }

  before do
    allow(RemoteTranslations::Caller).to receive_messages(
      configured?: true,
      available_locales: %w[de en es fr zh-CN pt-BR]
    )
  end

  context "locale with English as a fallback" do
    let!(:records) { [create(:proposal)] }
    let(:component) { Layout::RemoteTranslationsButtonComponent.new(records) }

    before do
      allow(I18n.fallbacks).to receive(:[]).and_return([:en])
      Globalize.set_fallbacks_to_all_available_locales
    end

    it "displays the text in English" do
      I18n.with_locale(:de) { render_inline component }

      expect(page).to have_css ".remote-translations-button"
      expect(page).to have_content "The original content of this page is not available in your language. " \
                                   "Would you like to translate it?"
    end

    it "displays the text in English with a locale needing parsing" do
      I18n.with_locale(:"zh-CN") { render_inline component }

      expect(page).to have_css ".remote-translations-button"
      expect(page).to have_content "The original content of this page is not available in your language. " \
                                   "Would you like to translate it?"
    end
  end

  context "locale with Spanish as a fallback" do
    let!(:records) { [create(:proposal)] }
    let(:component) { Layout::RemoteTranslationsButtonComponent.new(records) }

    before do
      allow(I18n.fallbacks).to receive(:[]).and_return([:es])
      Globalize.set_fallbacks_to_all_available_locales
    end

    it "displays the text in Spanish" do
      I18n.with_locale(:fr) { render_inline component }

      expect(page).to have_css ".remote-translations-button"
      expect(page).to have_content "El contenido de esta página no está disponible en tu idioma. " \
                                   "¿Te gustaría traducirlo?"
    end

    it "displays the text in Spanish with a locale needing parsing" do
      I18n.with_locale(:"pt-BR") { render_inline component }

      expect(page).to have_css ".remote-translations-button"
      expect(page).to have_content "El contenido de esta página no está disponible en tu idioma. " \
                                   "¿Te gustaría traducirlo?"
    end
  end

  describe "#render?" do
    it "is not rendered when the locale isn't included in microsoft translate client" do
      records = [create(:proposal)]

      I18n.with_locale(:nl) { render_inline Layout::RemoteTranslationsButtonComponent.new(records) }

      expect(page).not_to be_rendered
    end

    it "is not rendered when there aren't any remote translations" do
      render_inline Layout::RemoteTranslationsButtonComponent.new([])

      expect(page).not_to be_rendered
    end

    it "is not rendered when collections are already translated" do
      proposal = create(:proposal)
      comment = create(:comment, commentable: proposal)

      render_inline Layout::RemoteTranslationsButtonComponent.new([proposal, comment])

      expect(page).not_to be_rendered
    end

    it "is not rendered when the resource class is not translatable" do
      legislation_proposal = create(:legislation_proposal)

      I18n.with_locale(:es) do
        render_inline Layout::RemoteTranslationsButtonComponent.new([legislation_proposal])

        expect(page).not_to be_rendered
      end
    end

    it "is not rendered when remote translations are not configured" do
      allow(RemoteTranslations::Caller).to receive(:configured?).and_return(false)
      proposal = create(:proposal)
      comment = create(:comment, commentable: proposal)

      I18n.with_locale(:es) do
        render_inline Layout::RemoteTranslationsButtonComponent.new([proposal, comment])

        expect(page).not_to be_rendered
      end
    end
  end
end
