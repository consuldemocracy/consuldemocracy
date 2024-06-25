require "rails_helper"

describe Admin::LocalesController do
  describe "PATCH update" do
    it "cannot be accessed on the main tenant" do
      sign_in create(:administrator).user

      patch :update, params: { setting_locales_settings: { default: :es, enabled: [:en, :fr] }}

      expect(Setting.default_locale).to eq :en
      expect(response).to redirect_to "/"
    end

    it "can be accessed on other tenants" do
      create(:tenant, schema: "international")

      Tenant.switch("international") do
        sign_in create(:administrator).user

        patch :update, params: { setting_locales_settings: { default: :es, enabled: [:en, :fr] }}

        expect(Setting.enabled_locales).to match_array [:en, :es, :fr]
        expect(Setting.default_locale).to eq :es
      end
    end
  end
end
