require "rails_helper"

describe Layout::CommonHTMLAttributesComponent do
  let(:component) { Layout::CommonHTMLAttributesComponent.new }

  context "with multitenancy disabled" do
    before { allow(Rails.application.config).to receive(:multitenancy).and_return(false) }

    it "includes the default language by default" do
      render_inline component

      expect(page.text).to eq 'lang="en"'
    end

    it "includes the current language" do
      I18n.with_locale(:es) { render_inline component }

      expect(page.text).to eq 'lang="es"'
    end
  end

  context "with multitenancy enabled" do
    it "includes a class with the 'public' suffix for the default tenant" do
      render_inline component

      expect(page.text).to eq 'lang="en" class="tenant-public"'
    end

    it "includes a class with the schema name as suffix for other tenants" do
      allow(Tenant).to receive(:current_schema).and_return "private"

      render_inline component

      expect(page.text).to eq 'lang="en" class="tenant-private"'
    end
  end

  context "RTL languages" do
    let!(:default_enforce) { I18n.enforce_available_locales }

    before do
      I18n.enforce_available_locales = false
      allow(I18n).to receive(:available_locales).and_return(%i[ar en es])
    end

    after { I18n.enforce_available_locales = default_enforce }

    context "with multitenancy disabled" do
      before { allow(Rails.application.config).to receive(:multitenancy).and_return(false) }

      it "includes the dir attribute" do
        I18n.with_locale(:ar) { render_inline component }

        expect(page.text).to eq 'dir="rtl" lang="ar"'
      end
    end

    context "with multitenancy enabled" do
      it "includes the dir and the class attributes" do
        I18n.with_locale(:ar) { render_inline component }

        expect(page.text).to eq 'dir="rtl" lang="ar" class="tenant-public"'
      end
    end
  end
end
