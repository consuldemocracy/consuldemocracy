require "rails_helper"

describe RemoteTranslations::Microsoft::AvailableLocales do
  describe ".available_locales" do
    it "includes locales with the same format as I18n.available_locales" do
      allow(RemoteTranslations::Microsoft::AvailableLocales).to receive(:remote_available_locales)
                                                            .and_return(%w[de en es fr pt zh-Hans])

      available_locales = RemoteTranslations::Microsoft::AvailableLocales.available_locales
      expect(available_locales).to eq %w[de en es fr pt-BR zh-CN]
    end
  end
end
