require "rails_helper"

describe Globalizable do
  before do
    dummy_banner = Class.new(ApplicationRecord) do
      def self.name
        "DummyBanner"
      end
      self.table_name = "banners"

      translates :title, touch: true
      include Globalizable

      has_many :translations, class_name: "DummyBanner::Translation", foreign_key: "banner_id"

      validates_translation :title, length: { minimum: 7 }
    end

    stub_const("DummyBanner", dummy_banner)
  end

  describe ".validates_translation" do
    it "validates length for the default locale" do
      Setting["locales.default"] = "es"

      dummy = DummyBanner.new
      dummy.translations.build(locale: "es", title: "Short")
      dummy.translations.build(locale: "fr", title: "Long enough")

      I18n.with_locale(:fr) do
        expect(dummy).not_to be_valid
      end
    end

    it "does not validate length for other locales" do
      Setting["locales.default"] = "es"

      dummy = DummyBanner.new
      dummy.translations.build(locale: "es", title: "Long enough")
      dummy.translations.build(locale: "fr", title: "Long enough")
      dummy.translations.build(locale: "en", title: "Short")

      I18n.with_locale(:fr) do
        expect(dummy).to be_valid
      end
    end
  end
end
