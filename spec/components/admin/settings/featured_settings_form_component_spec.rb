require "rails_helper"

describe Admin::Settings::FeaturedSettingsFormComponent do
  let(:setting) { create(:setting, key: "feature.goodness") }
  let(:component) { Admin::Settings::FeaturedSettingsFormComponent.new(setting) }

  it "includes an aria-labelledby attribute" do
    render_inline component

    expect(page).to have_button count: 1
    expect(page).to have_css "button[aria-labelledby='title_setting_#{setting.id}']"
  end

  describe "aria-describedby attribute" do
    it "is rendered by default" do
      render_inline component

      expect(page).to have_css "button[aria-describedby='description_setting_#{setting.id}']"
    end

    it "is not rendered when the describedby option is false" do
      render_inline Admin::Settings::FeaturedSettingsFormComponent.new(setting, describedby: false)

      expect(page).not_to have_css "[aria-describedby]"
    end
  end

  describe "aria-pressed attribute" do
    it "is true when the setting is enabled" do
      setting.update!(value: "active")

      render_inline component

      expect(page).to have_css "button[aria-pressed='true']"
    end

    it "is false when the setting is disabled" do
      setting.update!(value: "")

      render_inline component

      expect(page).to have_css "button[aria-pressed='false']"
    end
  end

  describe "button text" do
    it "reflects the status when the setting is enabled" do
      setting.update!(value: "active")

      render_inline component

      expect(page).to have_button "Yes"
    end

    it "reflects the status when the setting is disabled" do
      setting.update!(value: "")

      render_inline component

      expect(page).to have_button "No"
    end
  end
end
