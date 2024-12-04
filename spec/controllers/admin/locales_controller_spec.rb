require "rails_helper"

describe Admin::LocalesController do
  describe "PATCH update" do
    it "checks permissions to update locales settings" do
      user = create(:administrator).user
      restricted_ability = user.ability.tap { |ability| ability.cannot :update, Setting::LocalesSettings }

      sign_in user
      allow(controller).to receive(:current_ability).and_return(restricted_ability)
      patch :update, params: { setting_locales_settings: { default: :es, enabled: [:en, :fr] }}

      expect(response).to redirect_to "/"
      expect(Setting.default_locale).to eq :en
    end
  end
end
