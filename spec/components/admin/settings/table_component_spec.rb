require "rails_helper"

describe Admin::Settings::TableComponent do
  describe "#key_header" do
    it "returns correct table header for the setting name colums" do
      render_inline Admin::Settings::TableComponent.new setting_name: "feature"

      expect(page).to have_content("Feature")

      render_inline Admin::Settings::TableComponent.new setting_name: "setting"

      expect(page).to have_content("Setting")

      render_inline Admin::Settings::TableComponent.new setting_name: "remote_census_general_name"

      expect(page).to have_content("General Information")

      render_inline Admin::Settings::TableComponent.new setting_name: "remote_census_request_name"

      expect(page).to have_content("Request Data")

      render_inline Admin::Settings::TableComponent.new setting_name: "remote_census_response_name"

      expect(page).to have_content("Response Data")
    end
  end

  describe "#value_header" do
    it "returns correct table header for the setting interface column" do
      render_inline Admin::Settings::TableComponent.new setting_name: "feature"

      expect(page).to have_content("Enabled")

      render_inline Admin::Settings::TableComponent.new setting_name: "setting"

      expect(page).to have_content("Value")
    end
  end

  describe "#table_class" do
    it "returns the `mixed-settings-table` by default" do
      render_inline Admin::Settings::TableComponent.new setting_name: "feature"

      expect(page).to have_css(".mixed-settings-table")
    end

    it "returns the given table_class" do
      render_inline Admin::Settings::TableComponent.new setting_name: "feature", table_class: "my-table-class"

      expect(page).not_to have_css(".mixed-settings-table")
      expect(page).to have_css(".my-table-class")
    end
  end
end
