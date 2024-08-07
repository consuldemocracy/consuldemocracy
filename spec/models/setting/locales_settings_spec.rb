require "rails_helper"

describe Setting::LocalesSettings do
  describe "#update!" do
    it "saves the default locale in the enabled ones when nothing is enabled" do
      Setting::LocalesSettings.new.update!(default: "es", enabled: %w[])
      updated_locales_settings = Setting::LocalesSettings.new

      expect(updated_locales_settings.default).to eq :es
      expect(updated_locales_settings.enabled).to match_array [:es]
    end
  end
end
