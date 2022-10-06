require "rails_helper"

describe Layout::CommonHTMLAttributesComponent do
  let(:component) { Layout::CommonHTMLAttributesComponent.new }

  it "includes the default language by default" do
    render_inline component

    expect(page.text).to eq 'lang="en"'
  end

  it "includes the current language" do
    I18n.with_locale(:es) { render_inline component }

    expect(page.text).to eq 'lang="es"'
  end

  context "RTL languages" do
    let!(:default_enforce) { I18n.enforce_available_locales }

    before do
      I18n.enforce_available_locales = false
      allow(I18n).to receive(:available_locales).and_return(%i[ar en es])
    end

    after { I18n.enforce_available_locales = default_enforce }

    it "includes the dir attribute" do
      I18n.with_locale(:ar) { render_inline component }

      expect(page.text).to eq 'dir="rtl" lang="ar"'
    end
  end
end
