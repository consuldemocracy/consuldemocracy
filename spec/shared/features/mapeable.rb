shared_examples "mapeable" do |mapeable_factory_name, mapeable_association_name, mapeable_new_path, mapeable_edit_path, mapeable_show_path, mapeable_path_arguments|

  include ActionView::Helpers

  let!(:user)         { create(:user, :level_two) }

  before do
    Setting['feature.map'] = true
  end

  describe "At #{mapeable_new_path}" do

    let!(:arguments)    { {} }
    let!(:mapeable)     { create("#{mapeable_factory_name}".to_sym) }
    let!(:map_location) { create(:map_location, "#{mapeable_factory_name}_map_location".to_sym, "#{mapeable_association_name}": mapeable) }

    before { set_arguments(arguments, mapeable, mapeable_path_arguments) }

    scenario "Should not show marker by default on create #{mapeable_factory_name}", :js do
      login_as user
      visit send(mapeable_new_path, arguments)

      send("fill_in_#{mapeable_factory_name}_form")

      within ".map_location" do
        expect(page).not_to have_css(".map-icon")
      end
    end

    scenario "Should show marker on create #{mapeable_factory_name} when click on map", :js do
      login_as user
      visit send(mapeable_new_path, arguments)

      send("fill_in_#{mapeable_factory_name}_form")
      find("#new_map_location").click

      within ".map_location" do
        expect(page).to have_css(".map-icon")
      end
    end

    scenario "Should create #{mapeable_factory_name} with map", :js do
      login_as user
      visit send(mapeable_new_path, arguments)

      send("fill_in_#{mapeable_factory_name}_form")
      find("#new_map_location").click
      send("submit_#{mapeable_factory_name}_form")

      expect(page).to have_css(".map_location")
    end

    scenario "Can not display map on #{mapeable_factory_name} when not fill marker on map", :js do
      login_as user
      visit send(mapeable_new_path, arguments)

      send("fill_in_#{mapeable_factory_name}_form")
      expect(page).to have_css ".map_location"
      send("submit_#{mapeable_factory_name}_form")

      expect(page).not_to have_css(".map_location")
    end

    scenario "Can not display map on #{mapeable_factory_name} when feature.map is disabled", :js do
      Setting['feature.map'] = false
      login_as user
      visit send(mapeable_new_path, arguments)

      send("fill_in_#{mapeable_factory_name}_form")
      expect(page).not_to have_css ".map_location"
      send("submit_#{mapeable_factory_name}_form")

      expect(page).not_to have_css(".map_location")
    end

  end

  describe "At #{mapeable_edit_path}" do

    let!(:mapeable)     { create("#{mapeable_factory_name}".to_sym) }
    let!(:map_location) { create(:map_location, "#{mapeable_factory_name}_map_location".to_sym, "#{mapeable_association_name}": mapeable) }

    before { skip } unless mapeable_edit_path.present?

    scenario "Should edit map on #{mapeable_factory_name} and contain default values", :js do
      login_as mapeable.author

      visit send(mapeable_edit_path, id: mapeable.id)

      expect(page).to have_content "Navigate the map to the location and place the marker."
      validate_latitude_longitude(mapeable_factory_name)
    end

    scenario "Should edit default values from map on #{mapeable_factory_name} edit page", :js do
      login_as mapeable.author

      visit send(mapeable_edit_path, id: mapeable.id)
      find(".map_location").click
      click_on("Save changes")
      mapeable.reload

      expect(page).to have_css(".map_location")
      expect(page).not_to have_selector(".map_location[data-marker-latitude='#{map_location.latitude}']")
      expect(page).to have_selector(".map_location[data-marker-latitude='#{mapeable.map_location.latitude}']")
    end

    scenario "Should edit mapeable on #{mapeable_factory_name} without change map", :js do
      login_as mapeable.author

      visit send(mapeable_edit_path, id: mapeable.id)
      fill_in "#{mapeable_factory_name}_title", with: "New title"
      click_on("Save changes")
      mapeable.reload

      expect(page).to have_css(".map_location")
      expect(page).to have_selector(".map_location[data-marker-latitude='#{map_location.latitude}']")
      expect(page).to have_selector(".map_location[data-marker-latitude='#{mapeable.map_location.latitude}']")
    end

    scenario "Can not display map on #{mapeable_factory_name} edit when remove map marker", :js do
      login_as mapeable.author

      visit send(mapeable_edit_path, id: mapeable.id)
      click_link "Remove map marker"
      click_on "Save changes"

      expect(page).not_to have_css(".map_location")
    end

    scenario "Can not display map on #{mapeable_factory_name} edit when feature.map is disabled", :js do
      Setting['feature.map'] = false
      login_as mapeable.author

      visit send(mapeable_edit_path, id: mapeable.id)
      fill_in "#{mapeable_factory_name}_title", with: "New title"
      click_on("Save changes")

      expect(page).not_to have_css(".map_location")
    end

  end

  describe "At #{mapeable_show_path}" do

    let!(:arguments)    { {} }
    let!(:mapeable)     { create("#{mapeable_factory_name}".to_sym) }
    let!(:map_location) { create(:map_location, "#{mapeable_factory_name}_map_location".to_sym, "#{mapeable_association_name}": mapeable) }

    before { set_arguments(arguments, mapeable, mapeable_path_arguments) }

    scenario "Should display map on #{mapeable_factory_name} show page", :js do
      arguments.merge!("id": mapeable.id)

      visit send(mapeable_show_path, arguments)

      expect(page).to have_css(".map_location")
    end

    scenario "Should not display map on #{mapeable_factory_name} show when marker is not defined", :js do
      mapeable_without_map = create("#{mapeable_factory_name}".to_sym)
      set_arguments(arguments, mapeable_without_map, mapeable_path_arguments)
      arguments.merge!("id": mapeable_without_map.id)

      visit send(mapeable_show_path, arguments)

      expect(page).not_to have_css(".map_location")
    end

    scenario "Should not display map on #{mapeable_factory_name} show page when feature.map is disable", :js do
      Setting['feature.map'] = false
      arguments.merge!("id": mapeable.id)

      visit send(mapeable_show_path, arguments)

      expect(page).not_to have_css(".map_location")
    end

  end

end

def fill_in_proposal_form
  fill_in 'proposal_title', with: 'Help refugees'
  fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
  fill_in 'proposal_summary', with: 'In summary, what we want is...'
end

def submit_proposal_form
  check :proposal_terms_of_service
  click_button 'Create proposal'

  click_link 'Not now, go to my proposal'
end

def validate_latitude_longitude(mapeable_factory_name)
  expect(find("##{mapeable_factory_name}_map_location_attributes_latitude", visible: false).value).to eq "51.48"
  expect(find("##{mapeable_factory_name}_map_location_attributes_longitude", visible: false).value).to eq "0.0"
  expect(mapeable.map_location.latitude).to eq 51.48
  expect(mapeable.map_location.longitude).to eq 0.0
end

def fill_in_budget_investment_form
  page.select mapeable.heading.name_scoped_by_group, from: :budget_investment_heading_id
  fill_in :budget_investment_title, with: "Budget investment title"
  fill_in_ckeditor "budget_investment_description", with: "Budget investment description"
  check :budget_investment_terms_of_service
end

def submit_budget_investment_form
  check :budget_investment_terms_of_service
  click_button 'Create Investment'
end

def set_arguments(arguments, mapeable, mapeable_path_arguments)
  if mapeable_path_arguments
    mapeable_path_arguments.each do |argument_name, path_to_value|
      arguments.merge!("#{argument_name}": mapeable.send(path_to_value))
    end
  end
end
