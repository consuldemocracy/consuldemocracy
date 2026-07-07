require "rails_helper"

describe Shared::GlobalizeLocalesComponent do
  before do
    dummy_banner = Class.new(ApplicationRecord) do
      def self.name
        "DummyBanner"
      end
      self.table_name = "banners"

      translates :title, touch: true
      validates :title, presence: true
      include Globalizable

      has_many :translations, class_name: "DummyBanner::Translation", foreign_key: "banner_id"
    end

    stub_const("DummyBanner", dummy_banner)
  end

  describe "Language selector" do
    it "only includes enabled locales" do
      Setting["locales.enabled"] = "en nl"

      I18n.with_locale(:en) do
        render_inline Shared::GlobalizeLocalesComponent.new

        expect(page).to have_select "Current language", options: ["English"]
      end

      I18n.with_locale(:es) do
        render_inline Shared::GlobalizeLocalesComponent.new

        expect(page).to have_select "Idioma actual", options: []
      end
    end
  end

  describe "links to destroy languages" do
    it "only includes enabled locales" do
      Setting["locales.enabled"] = "en nl"

      I18n.with_locale(:en) do
        render_inline Shared::GlobalizeLocalesComponent.new

        expect(page).to have_css "a[data-locale]", count: 1
      end

      I18n.with_locale(:es) do
        render_inline Shared::GlobalizeLocalesComponent.new

        expect(page).not_to have_css "a[data-locale]"
      end
    end
  end

  describe "Add language selector" do
    it "only includes enabled locales" do
      Setting["locales.enabled"] = "en nl"

      render_inline Shared::GlobalizeLocalesComponent.new

      expect(page).to have_select "Add language", options: ["", "English", "Nederlands"]
    end

    describe "errors" do
      it "adds ARIA attributes when there are errors" do
        dummy_record = DummyBanner.new
        allow(dummy_record).to receive(:new_record?).and_return(false)
        dummy_record.valid?

        render_inline Shared::GlobalizeLocalesComponent.new(dummy_record)

        expect(page).to have_css "select[aria-invalid][aria-errormessage='select_language_error']"
        expect(page).to have_css "#select_language_error",
                                 exact_text: "It's mandatory to provide at least one translation"
      end

      it "does not add an error field when there aren't any errors" do
        dummy_record = DummyBanner.new
        dummy_record.valid?

        render_inline Shared::GlobalizeLocalesComponent.new(dummy_record)

        expect(page).not_to have_css "select[aria-invalid]"
        expect(page).not_to have_css "select[aria-errormessage]"
        expect(page).not_to have_css "#select_language_error"
        expect(page).not_to have_content "provide at least one translation"
      end

      it "does not add an error field when there isn't a resource" do
        render_inline Shared::GlobalizeLocalesComponent.new

        expect(page).not_to have_css "select[aria-invalid]"
        expect(page).not_to have_css "select[aria-errormessage]"
        expect(page).not_to have_css "#select_language_error"
        expect(page).not_to have_content "provide at least one translation"
      end
    end
  end
end
