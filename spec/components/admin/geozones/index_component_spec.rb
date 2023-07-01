require "rails_helper"

describe Admin::Geozones::IndexComponent, :admin do
  describe "Coordinates description" do
    it "includes whether coordinates are defined or not" do
      geozones = [
        create(:geozone, :with_geojson, name: "GeoJSON", external_code: "1", census_code: "2"),
        create(:geozone, :with_html_coordinates, name: "HTML", external_code: "3", census_code: "4"),
        create(:geozone, :with_geojson, :with_html_coordinates, name: "With both", external_code: "6", census_code: "7"),
        create(:geozone, name: "With none", external_code: "8", census_code: "9")
      ]

      render_inline Admin::Geozones::IndexComponent.new(geozones)

      expect(page).to have_table with_rows: [
        ["GeoJSON",   "1", "2", "No",  "Yes", "Edit Delete"],
        ["HTML",      "3", "4", "Yes", "No",  "Edit Delete"],
        ["With both", "6", "7", "Yes", "Yes", "Edit Delete"],
        ["With none", "8", "9", "No",  "No",  "Edit Delete"]
      ]
    end
  end
end
