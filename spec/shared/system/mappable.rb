shared_examples "mappable" do |mappable_factory_name, mappable_association_name, mappable_new_path, mappable_edit_path, mappable_show_path, mappable_path_arguments, management: false|
  let!(:user)         { create(:user, :level_two) }
  let!(:arguments)    { {} }
  let!(:mappable)     { create(mappable_factory_name.to_s.to_sym) }
  let!(:map_location) { create(:map_location, "#{mappable_factory_name}_map_location".to_sym, "#{mappable_association_name}": mappable) }
  let(:management)    { management }

  before do
    Setting["feature.map"] = true
  end

  describe "At #{mappable_new_path}" do
    before { set_arguments(arguments, mappable, mappable_path_arguments) }

    scenario "Should not show marker by default on create #{mappable_factory_name}", :js do
      do_login_for user
      visit send(mappable_new_path, arguments)

      send("fill_in_#{mappable_factory_name}_form")

      within ".map_location" do
        expect(page).not_to have_css(".map-icon")
      end
    end

    scenario "Should show marker on create #{mappable_factory_name} when click on map", :js do
      do_login_for user
      visit send(mappable_new_path, arguments)

      send("fill_in_#{mappable_factory_name}_form")
      find("#new_map_location").click

      within ".map_location" do
        expect(page).to have_css(".map-icon")
      end
    end

    scenario "Should create #{mappable_factory_name} with map", :js do
      do_login_for user
      visit send(mappable_new_path, arguments)

      send("fill_in_#{mappable_factory_name}_form")
      find("#new_map_location").click
      send("submit_#{mappable_factory_name}_form")

      expect(page).to have_css(".map_location")
    end

    scenario "Can not display map on #{mappable_factory_name} when not fill marker on map", :js do
      do_login_for user
      visit send(mappable_new_path, arguments)

      send("fill_in_#{mappable_factory_name}_form")
      expect(page).to have_css ".map_location"
      check "#{mappable_factory_name}_skip_map"
      send("submit_#{mappable_factory_name}_form")

      expect(page).not_to have_css(".map_location")
    end

    scenario "Can not display map on #{mappable_factory_name} when feature.map is disabled", :js do
      Setting["feature.map"] = false
      do_login_for user
      visit send(mappable_new_path, arguments)

      send("fill_in_#{mappable_factory_name}_form")
      expect(page).not_to have_css ".map_location"
      send("submit_#{mappable_factory_name}_form")

      expect(page).not_to have_css(".map_location")
    end

    scenario "Errors on create" do
      do_login_for user
      visit send(mappable_new_path, arguments)

      send("submit_#{mappable_factory_name}_form")

      expect(page).to have_content "Map location can't be blank"
    end

    describe "When restoring the page from browser history" do
      before { Setting["org_name"] = "CONSUL" }

      scenario "map should not be duplicated", :js do
        do_login_for user
        visit send(mappable_new_path, arguments)

        if management
          click_link "Select user"

          expect(page).to have_content "User management"
        else
          click_link "Help"

          expect(page).to have_content "CONSUL is a platform for citizen participation"
        end

        go_back

        within ".map_location" do
          expect(page).to have_css(".leaflet-map-pane", count: 1)
        end
      end

      scenario "keeps marker and zoom defined by the user", :js do
        do_login_for user
        visit send(mappable_new_path, arguments)

        within ".map_location" do
          expect(page).not_to have_css(".map-icon")
        end
        expect(page.execute_script("return App.Map.maps[0].getZoom();")).to eq(10)

        map_zoom_in
        find("#new_map_location").click

        within ".map_location" do
          expect(page).to have_css(".map-icon")
        end

        if management
          click_link "Select user"

          expect(page).to have_content "User management"
        else
          click_link "Help"

          expect(page).to have_content "CONSUL is a platform for citizen participation"
        end

        go_back

        within ".map_location" do
          expect(page).to have_css(".map-icon")
          expect(page.execute_script("return App.Map.maps[0].getZoom();")).to eq(11)
        end
      end

      scenario "shows marker at map center", :js do
        do_login_for user
        visit send(mappable_new_path, arguments)

        within ".map_location" do
          expect(page).not_to have_css(".map-icon")
        end

        place_map_at(-68.592487, -62.391357)
        find("#new_map_location").click

        within ".map_location" do
          expect(page).to have_css(".map-icon")
        end

        if management
          click_link "Select user"

          expect(page).to have_content "User management"
        else
          click_link "Help"

          expect(page).to have_content "CONSUL is a platform for citizen participation"
        end

        go_back

        within ".map_location" do
          expect(page).to have_css(".map-icon")
        end
      end
    end

    scenario "Skip map", :js do
      do_login_for user
      visit send(mappable_new_path, arguments)

      send("fill_in_#{mappable_factory_name}_form")
      check "#{mappable_factory_name}_skip_map"
      send("submit_#{mappable_factory_name}_form")

      expect(page).not_to have_content "Map location can't be blank"
    end

    scenario "Toggle map", :js do
      do_login_for user
      visit send(mappable_new_path, arguments)

      check "#{mappable_factory_name}_skip_map"

      expect(page).not_to have_css(".map")
      expect(page).not_to have_content("Remove map marker")

      uncheck "#{mappable_factory_name}_skip_map"

      expect(page).to have_css(".map")
      expect(page).to have_content("Remove map marker")
    end
  end

  describe "At #{mappable_edit_path}" do
    before { skip } if mappable_edit_path.blank?

    scenario "Should edit map on #{mappable_factory_name} and contain default values", :js do
      do_login_for mappable.author

      visit send(mappable_edit_path, id: mappable.id)

      expect(page).to have_content "Navigate the map to the location and place the marker."
      validate_latitude_longitude(mappable_factory_name)
    end

    scenario "Should edit default values from map on #{mappable_factory_name} edit page", :js do
      do_login_for mappable.author

      visit send(mappable_edit_path, id: mappable.id)
      find(".map_location").click
      click_on("Save changes")
      mappable.reload

      expect(page).to have_css(".map_location")
      expect(page).not_to have_selector(".map_location[data-marker-latitude='#{map_location.latitude}']")
      expect(page).to have_selector(".map_location[data-marker-latitude='#{mappable.map_location.latitude}']")
    end

    scenario "Should edit mappable on #{mappable_factory_name} without change map", :js do
      do_login_for mappable.author

      visit send(mappable_edit_path, id: mappable.id)
      fill_in "#{mappable_factory_name.camelize} title", with: "New title"
      click_on("Save changes")
      mappable.reload

      expect(page).to have_css(".map_location")
      expect(page).to have_selector(".map_location[data-marker-latitude='#{map_location.latitude}']")
      expect(page).to have_selector(".map_location[data-marker-latitude='#{mappable.map_location.latitude}']")
    end

    scenario "Can not display map on #{mappable_factory_name} edit when remove map marker", :js do
      do_login_for mappable.author

      visit send(mappable_edit_path, id: mappable.id)
      click_link "Remove map marker"
      check "#{mappable_factory_name}_skip_map"
      click_on "Save changes"

      expect(page).not_to have_css(".map_location")
    end

    scenario "Can not display map on #{mappable_factory_name} edit when feature.map is disabled", :js do
      Setting["feature.map"] = false
      do_login_for mappable.author

      visit send(mappable_edit_path, id: mappable.id)
      fill_in "#{mappable_factory_name.camelize} title", with: "New title"
      click_on("Save changes")

      expect(page).not_to have_css(".map_location")
    end

    scenario "No errors on update", :js do
      skip ""
      do_login_for mappable.author

      visit send(mappable_edit_path, id: mappable.id)
      click_link "Remove map marker"
      click_on "Save changes"

      expect(page).not_to have_content "Map location can't be blank"
    end

    scenario "No need to skip map on update" do
      do_login_for mappable.author

      visit send(mappable_edit_path, id: mappable.id)
      click_link "Remove map marker"
      click_on "Save changes"

      expect(page).not_to have_content "Map location can't be blank"
    end
  end

  describe "At #{mappable_show_path}" do
    before do
      set_arguments(arguments, mappable, mappable_path_arguments)
      do_login_for(user) if management
    end

    scenario "Should display map and marker on #{mappable_factory_name} show page", :js do
      arguments[:id] = mappable.id

      visit send(mappable_show_path, arguments)

      within ".map_location" do
        expect(page).to have_css(".map-icon")
      end
    end

    scenario "Should not display map on #{mappable_factory_name} show when marker is not defined", :js do
      mappable_without_map = create(mappable_factory_name.to_s.to_sym)
      set_arguments(arguments, mappable_without_map, mappable_path_arguments)
      arguments[:id] = mappable_without_map.id

      visit send(mappable_show_path, arguments)

      expect(page).not_to have_css(".map_location")
    end

    scenario "Should not display map on #{mappable_factory_name} show page when feature.map is disable", :js do
      Setting["feature.map"] = false
      arguments[:id] = mappable.id

      visit send(mappable_show_path, arguments)

      expect(page).not_to have_css(".map_location")
    end
  end
end

def do_login_for(user)
  if management
    login_as_manager
    login_managed_user(user)
  else
    login_as(user)
  end
end

def fill_in_proposal_form
  fill_in "Proposal title", with: "Help refugees"
  fill_in "Proposal summary", with: "In summary, what we want is..."
end

def submit_proposal_form
  check :proposal_terms_of_service
  click_button "Create proposal"

  if page.has_content?("Not now, go to my proposal")
    click_link "Not now, go to my proposal"
  end
end

def validate_latitude_longitude(mappable_factory_name)
  expect(find("##{mappable_factory_name}_map_location_attributes_latitude", visible: false).value).to eq "51.48"
  expect(find("##{mappable_factory_name}_map_location_attributes_longitude", visible: false).value).to eq "0.0"
  expect(mappable.map_location.latitude).to eq 51.48
  expect(mappable.map_location.longitude).to eq 0.0
end

def fill_in_budget_investment_form
  page.select mappable.heading.name_scoped_by_group, from: :budget_investment_heading_id
  fill_in "Title", with: "Budget investment title"
  fill_in_ckeditor "Description", with: "Budget investment description"
  check :budget_investment_terms_of_service
end

def submit_budget_investment_form
  check :budget_investment_terms_of_service
  click_button "Create Investment"
end

def set_arguments(arguments, mappable, mappable_path_arguments)
  mappable_path_arguments&.each do |argument_name, path_to_value|
    arguments.merge!("#{argument_name}": mappable.send(path_to_value))
  end
end

def map_zoom_in
  initial_zoom = page.execute_script("return App.Map.maps[0].getZoom();")
  find(".leaflet-control-zoom-in").click
  until page.execute_script("return App.Map.maps[0].getZoom() === #{initial_zoom + 1};") do
    sleep 0.01
  end
end

def place_map_at(latitude, longitude)
  page.execute_script("App.Map.maps[0].setView(new L.LatLng(#{latitude}, #{longitude}))")

  until page.execute_script("return App.Map.maps[0].getCenter().lat === #{latitude};") do
    sleep 0.01
  end
end
