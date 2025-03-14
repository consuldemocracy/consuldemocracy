require "rails_helper"

describe Layout::LocaleSwitcherComponent do
  let(:component) { Layout::LocaleSwitcherComponent.new }

  around do |example|
    with_request_url("/") { example.run }
  end

  context "with only one language" do
    before { allow(I18n).to receive(:available_locales).and_return([:en]) }

    it "doesn't render anything" do
      render_inline component

      expect(page).not_to be_rendered
    end
  end

  context "with many languages" do
    before { allow(I18n).to receive(:available_locales).and_return(%i[de en es fr nl]) }

    it "renders a form to select the language" do
      render_inline component

      expect(page).to have_css "form"
      expect(page).to have_select "Language:", options: %w[Deutsch English Español Français Nederlands]
      expect(page).not_to have_css "ul"
    end

    it "selects the current locale" do
      render_inline component

      expect(page).to have_select "Language:", selected: "English"
    end

    context "missing language names" do
      let!(:default_enforce) { I18n.enforce_available_locales }

      before do
        I18n.enforce_available_locales = false
        allow(I18n).to receive(:available_locales).and_return(%i[de en es fr nl wl])
      end

      after { I18n.enforce_available_locales = default_enforce }

      it "renders the locale key" do
        render_inline component

        expect(page).to have_select "Language:", with_options: ["wl"]
      end
    end
  end

  context "with a few languages" do
    before do
      allow(I18n).to receive(:available_locales).and_return(%i[en es fr])
    end

    it "renders a list of links" do
      render_inline component

      expect(page).to have_css "ul"
      expect(page).to have_link "English", href: "/?locale=en"
      expect(page).to have_link "Español", href: "/?locale=es"
      expect(page).to have_link "Français", href: "/?locale=fr"
      expect(page).not_to have_css "form"
    end

    it "marks the current locale" do
      render_inline component

      expect(page).to have_css "[aria-current]", count: 1
      expect(page).to have_css "[aria-current]", exact_text: "English"
    end
  end

  context "when not all available locales are enabled" do
    before do
      allow(I18n).to receive(:available_locales).and_return(%i[en es fr])
      Setting["locales.default"] = "es"
      Setting["locales.enabled"] = "es fr"
    end

    it "displays the enabled locales" do
      render_inline component

      expect(page).to have_link count: 2
      expect(page).to have_link "Español"
      expect(page).to have_link "Français"
      expect(page).not_to have_link "English"
    end
  end
end
