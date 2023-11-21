require "rails_helper"

describe Admin::Settings::TableComponent do
  describe "#display_setting_name" do
    it "returns correct table header" do
      settings = Setting.limit(2)

      render_inline Admin::Settings::TableComponent.new settings: settings, setting_name: "setting"

      expect(page).to have_content("Setting")

      setting_name = "remote_census_general_name"
      render_inline Admin::Settings::TableComponent.new settings: settings, setting_name: setting_name

      expect(page).to have_content("General Information")

      setting_name = "remote_census_request_name"
      render_inline Admin::Settings::TableComponent.new settings: settings, setting_name: setting_name

      expect(page).to have_content("Request Data")

      setting_name = "remote_census_response_name"
      render_inline Admin::Settings::TableComponent.new settings: settings, setting_name: setting_name

      expect(page).to have_content("Response Data")
    end
  end
end
