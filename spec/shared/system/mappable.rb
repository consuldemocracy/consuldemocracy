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

    scenario "Should not show marker by default on create #{mappable_factory_name}" do
      do_login_for user, management: management
      visit send(mappable_new_path, arguments)

      send("fill_in_#{mappable_factory_name}_form")

      within ".map_location" do
        expect(page).not_to have_css(".map-icon")
      end
    end

    scenario "Should show marker on create #{mappable_factory_name} when click on map" do
      do_login_for user, management: management
      visit send(mappable_new_path, arguments)

      send("fill_in_#{mappable_factory_name}_form")
      find("#new_map_location").click

      within ".map_location" do
        expect(page).to have_css(".map-icon")
      end
    end

    scenario "Should create #{mappable_factory_name} with map" do
      do_login_for user, management: management
      visit send(mappable_new_path, arguments)

      send("fill_in_#{mappable_factory_name}_form")
      find("#new_map_location").click
      send("submit_#{mappable_factory_name}_form")

      within ".map_location" do
        expect(page).to have_css(".map-icon")
      end
    end

    scenario "Can not display map on #{mappable_factory_name} when not fill marker on map" do
      do_login_for user, management: management
      visit send(mappable_new_path, arguments)

      send("fill_in_#{mappable_factory_name}_form")
      expect(page).to have_css ".map_location"
      send("submit_#{mappable_factory_name}_form")

      expect(page).not_to have_css(".map_location")
    end

    scenario "Can not display map on #{mappable_factory_name} when feature.map is disabled" do
      Setting["feature.map"] = false
      do_login_for user, management: management
      visit send(mappable_new_path, arguments)

      send("fill_in_#{mappable_factory_name}_form")
      expect(page).not_to have_css ".map_location"
      send("submit_#{mappable_factory_name}_form")

      expect(page).not_to have_css(".map_location")
    end

    describe "When restoring the page from browser history" do
      before { Setting["org_name"] = "CONSUL" }

      scenario "map should not be duplicated" do
        do_login_for user, management: management
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

      scenario "keeps marker and zoom defined by the user" do
        do_login_for user, management: management
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

      scenario "shows marker at map center" do
        do_login_for user, management: management
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

    scenario "Skip map" do
      do_login_for user, management: management
      visit send(mappable_new_path, arguments)

      send("fill_in_#{mappable_factory_name}_form")
      send("submit_#{mappable_factory_name}_form")

      expect(page).not_to have_content "Map location can't be blank"
    end
  end

  describe "At #{mappable_edit_path}", if: mappable_edit_path.present? do
    scenario "Should edit map on #{mappable_factory_name} and contain default values" do
      mappable.map_location.update!(latitude: 51.48, longitude: 0.0)
      do_login_for mappable.author, management: management

      visit send(mappable_edit_path, id: mappable.id)

      expect(page).to have_content "Navigate the map to the location and place the marker."
      expect(page).to have_field "#{mappable_factory_name}_map_location_attributes_latitude", type: :hidden, with: "51.48"
      expect(page).to have_field "#{mappable_factory_name}_map_location_attributes_longitude", type: :hidden, with: "0.0"
    end

    scenario "Should edit default values from map on #{mappable_factory_name} edit page" do
      do_login_for mappable.author, management: management

      visit send(mappable_edit_path, id: mappable.id)
      find(".map_location").click
      click_on("Save changes")
      mappable.reload

      expect(page).to have_css(".map_location")
      expect(page).not_to have_selector(".map_location[data-marker-latitude='#{map_location.latitude}']")
      expect(page).to have_selector(".map_location[data-marker-latitude='#{mappable.map_location.latitude}']")
    end

    scenario "Should edit mappable on #{mappable_factory_name} without change map" do
      do_login_for mappable.author, management: management

      visit send(mappable_edit_path, id: mappable.id)
      fill_in "#{mappable_factory_name.camelize} title", with: "New title"
      click_on("Save changes")
      mappable.reload

      expect(page).to have_css(".map_location")
      expect(page).to have_selector(".map_location[data-marker-latitude='#{map_location.latitude}']")
      expect(page).to have_selector(".map_location[data-marker-latitude='#{mappable.map_location.latitude}']")
    end

    scenario "Can not display map on #{mappable_factory_name} edit when remove map marker" do
      do_login_for mappable.author, management: management

      visit send(mappable_edit_path, id: mappable.id)
      click_link "Remove map marker"
      click_on "Save changes"

      expect(page).not_to have_css(".map_location")
    end

    scenario "Can not display map on #{mappable_factory_name} edit when feature.map is disabled" do
      Setting["feature.map"] = false
      do_login_for mappable.author, management: management

      visit send(mappable_edit_path, id: mappable.id)
      fill_in "#{mappable_factory_name.camelize} title", with: "New title"
      click_on("Save changes")

      expect(page).not_to have_css(".map_location")
    end

    scenario "No need to skip map on update" do
      do_login_for mappable.author, management: management

      visit send(mappable_edit_path, id: mappable.id)
      click_link "Remove map marker"
      click_on "Save changes"

      expect(page).not_to have_content "Map location can't be blank"
    end
  end

  describe "At #{mappable_show_path}" do
    before do
      set_arguments(arguments, mappable, mappable_path_arguments)
    end

    scenario "Should display map and marker on #{mappable_factory_name} show page" do
      arguments[:id] = mappable.id

      do_login_for user, management: management if management
      visit send(mappable_show_path, arguments)

      within ".map_location" do
        expect(page).to have_css(".map-icon")
      end
    end

    scenario "Should not display map on #{mappable_factory_name} show when marker is not defined" do
      mappable_without_map = create(mappable_factory_name.to_s.to_sym)
      set_arguments(arguments, mappable_without_map, mappable_path_arguments)
      arguments[:id] = mappable_without_map.id

      do_login_for user, management: management if management
      visit send(mappable_show_path, arguments)

      expect(page).not_to have_css(".map_location")
    end

    scenario "Should not display map on #{mappable_factory_name} show page when feature.map is disable" do
      Setting["feature.map"] = false
      arguments[:id] = mappable.id

      do_login_for user, management: management if management
      visit send(mappable_show_path, arguments)

      expect(page).not_to have_css(".map_location")
    end
  end
end
