require "rails_helper"

describe Admin::SiteCustomization::InformationTexts::FormComponent do
  describe "enabled_translations fields" do
    it "renders fields for enabled locales" do
      Setting["locales.enabled"] = "en es"
      content = create(:i18n_content)

      render_inline Admin::SiteCustomization::InformationTexts::FormComponent.new([[content]])

      expect(page).to have_css "input[name^='enabled_translations']", count: 2, visible: :all
      expect(page).to have_css "input[name='enabled_translations[en]']", visible: :hidden
      expect(page).to have_css "input[name='enabled_translations[es]']", visible: :hidden
    end
  end

  describe "text fields" do
    it "renders fields for enabled locales" do
      Setting["locales.enabled"] = "en es"
      content = create(:i18n_content, key: "system.failure")

      render_inline Admin::SiteCustomization::InformationTexts::FormComponent.new([[content]])

      expect(page).to have_css "textarea[name^='contents[content_system.failure]']", count: 2, visible: :all
      expect(page).to have_field "contents[content_system.failure]values[value_en]"
      expect(page).to have_field "contents[content_system.failure]values[value_es]"
    end
  end
end
