require "rails_helper"

describe Admin::Locales::FormComponent do
  let(:default_locale) { :nl }
  let(:enabled_locales) { %i[en nl] }
  let(:locales_settings) { Setting::LocalesSettings.new(default: default_locale, enabled: enabled_locales) }
  let(:component) { Admin::Locales::FormComponent.new(locales_settings) }
  before { allow(I18n).to receive(:available_locales).and_return(%i[de en es nl]) }

  describe "default language selector" do
    it "renders radio buttons when there are only a few locales" do
      render_inline component

      page.find(:fieldset, "Default language") do |fieldset|
        expect(fieldset).to have_checked_field "Nederlands", type: :radio
        expect(fieldset).to have_unchecked_field "English", type: :radio
        expect(fieldset).to have_unchecked_field "Español", type: :radio
        expect(fieldset).to have_unchecked_field "Deutsch", type: :radio
      end

      expect(page).not_to have_select
    end

    it "renders a select when there are many locales" do
      allow(component).to receive(:select_field_threshold).and_return(3)

      render_inline component

      expect(page).not_to have_field type: :radio

      expect(page).to have_select "Default language",
                                  options: %w[English Español Deutsch Nederlands],
                                  selected: "Nederlands"
    end
  end

  describe "buttons to check all/none" do
    it "is not rendered when there are only a few locales" do
      render_inline component

      expect(page).not_to have_button "Select all"
      expect(page).not_to have_button "Select none"
    end

    it "is rendered when there are many locales" do
      allow(component).to receive(:select_field_threshold).and_return(3)

      render_inline component

      page.find(:fieldset, "Enabled languages") do |fieldset|
        expect(fieldset).to have_button "Select all"
        expect(fieldset).to have_button "Select none"
      end
    end
  end
end
