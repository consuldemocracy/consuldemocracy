require "rails_helper"

describe "Admin maps" do
  before do
    Setting["feature.map"] = true
    admin = create(:administrator)
    login_as(admin.user)
  end

  context "Index" do
    scenario "Display message if feature is disable" do
      Setting["feature.map"] = nil

      visit admin_maps_path

      expect(page).to have_content("To show the map to users you must enable \"Proposals and budget "\
                                   "investments geolocation\" on \"Features\" tab.")
    end

    scenario "Display default map" do
      visit admin_maps_path

      expect(page).to have_content("Map configuration")
      expect(page).to have_content("Default map")
      expect(page).to have_link("Create new map")
      expect(page).to have_link("Edit")
      expect(page).not_to have_link("Delete")
    end

    scenario "Display maps" do
      budget_1 = create(:budget)
      budget_2 = create(:budget)

      map_1 = create(:map, budget_id: budget_1.id)
      map_2 = create(:map, budget_id: budget_2.id)

      create(:map_location, map_id: map_1.id)
      create(:map_location, map_id: map_2.id)

      visit admin_maps_path

      within("#map_#{map_1.id}") do
        expect(page).to have_content budget_1.name
        expect(page).to have_link("Edit")
        expect(page).to have_link("Delete")
      end

      within("#map_#{map_2.id}") do
        expect(page).to have_content budget_2.name
        expect(page).to have_link("Edit")
        expect(page).to have_link("Delete")
      end

      within("#map_#{Map.default.id}") do
        expect(page).to have_content("Default map")
        expect(page).to have_link("Edit")
        expect(page).not_to have_link("Delete")
      end
    end

    scenario "Delete map from index" do
      budget_1 = create(:budget)
      budget_2 = create(:budget)

      map_1 = create(:map, budget_id: budget_1.id)
      map_2 = create(:map, budget_id: budget_2.id)

      create(:map_location, map_id: map_1.id)
      create(:map_location, map_id: map_2.id)

      visit admin_maps_path

      within("#map_#{map_1.id}") do
        expect(page).to have_content budget_1.name
        expect(page).to have_link("Edit")
        expect(page).to have_link("Delete")
      end

      within("#map_#{map_2.id}") do
        click_link("Delete")
      end

      expect(page).to have_content("Map deleted successfully.")
      expect(page).not_to have_content budget_2.name
    end
  end

  context "Create" do
    scenario "A new map is always created with default values" do
      create(:budget, name: "Budget with map")
      create(:budget, name: "Budget")

      visit admin_maps_path
      click_link "Create new map"

      select "Budget with map", from: "Budget"

      click_button "Continue"

      expect(page).to have_content("Map created succesfully.")
      expect(page).to have_selector("input[name='map_location[latitude]'][value=\"51.48\"]")
      expect(page).to have_selector("input[name='map_location[longitude]'][value=\"0.0\"]")
      expect(page).to have_selector("input[name='map_location[zoom]'][value=\"10\"]")
    end
  end

  context "Edit" do
    scenario "Edit using form" do
      budget = create(:budget)
      map = create(:map, budget_id: budget.id)
      create(:map_location, map_id: map.id)

      visit admin_maps_path

      within("#map_#{map.id}") do
        click_link("Edit")
      end

      fill_in "Latitude", with: "80"
      fill_in "Longitude", with: "40"
      fill_in "Zoom", with: "5"

      click_button "Save coordinates"

      expect(page).to have_content("Map updated succesfully.")
      expect(page).to have_selector("input[name='map_location[latitude]'][value=\"80.0\"]")
      expect(page).to have_selector("input[name='map_location[longitude]'][value=\"40.0\"]")
      expect(page).to have_selector("input[name='map_location[zoom]'][value=\"5\"]")
      expect(page).to have_current_path admin_map_map_location_path(map, map.map_location)
    end
  end
end
