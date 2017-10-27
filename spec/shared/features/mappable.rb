shared_examples "mappable" do |mappable_factory_name, mappable_association_name, mappable_new_path, mappable_edit_path, mappable_show_path, mappable_path_arguments|

  include ActionView::Helpers

  let!(:user) { create(:user, :level_two) }

  before do
    Setting['feature.map'] = true
  end

  describe "At #{mappable_new_path}" do

    let!(:arguments)    { {} }
    let!(:mappable)     { create(mappable_factory_name.to_s.to_sym) }
    let!(:map_location) { create(:map_location, "#{mappable_factory_name}_map_location".to_sym, "#{mappable_association_name}": mappable) }

    before { set_arguments(arguments, mappable, mappable_path_arguments) }

    scenario "Should not show marker by default on create #{mappable_factory_name}", :js do
      login_as user
      visit send(mappable_new_path, arguments)

      send("fill_in_#{mappable_factory_name}_form")

      within ".map_location" do
        expect(page).not_to have_css(".map-icon")
      end
    end

    scenario "Should show marker on create #{mappable_factory_name} when click on map", :js do
      login_as user
      visit send(mappable_new_path, arguments)

      send("fill_in_#{mappable_factory_name}_form")
      find("#new_map_location").click

      within ".map_location" do
        expect(page).to have_css(".map-icon")
      end
    end

    scenario "Should create #{mappable_factory_name} with map", :js do
      login_as user
      visit send(mappable_new_path, arguments)

      send("fill_in_#{mappable_factory_name}_form")
      find("#new_map_location").click
      send("submit_#{mappable_factory_name}_form")

      expect(page).to have_css(".map_location")
    end

    scenario "Can not display map on #{mappable_factory_name} when not fill marker on map", :js do
      login_as user
      visit send(mappable_new_path, arguments)

      send("fill_in_#{mappable_factory_name}_form")
      expect(page).to have_css ".map_location"
      send("submit_#{mappable_factory_name}_form")

      expect(page).not_to have_css(".map_location")
    end

    scenario "Can not display map on #{mappable_factory_name} when feature.map is disabled", :js do
      Setting['feature.map'] = false
      login_as user
      visit send(mappable_new_path, arguments)

      send("fill_in_#{mappable_factory_name}_form")
      expect(page).not_to have_css ".map_location"
      send("submit_#{mappable_factory_name}_form")

      expect(page).not_to have_css(".map_location")
    end

  end

  describe "At #{mappable_edit_path}" do

    let!(:mappable)     { create(mappable_factory_name.to_s.to_sym) }
    let!(:map_location) { create(:map_location, "#{mappable_factory_name}_map_location".to_sym, "#{mappable_association_name}": mappable) }

    before { skip } if mappable_edit_path.blank?

    scenario "Should edit map on #{mappable_factory_name} and contain default values", :js do
      login_as mappable.author

      visit send(mappable_edit_path, id: mappable.id)

      expect(page).to have_content "Navigate the map to the location and place the marker."
      validate_latitude_longitude(mappable_factory_name)
    end

    scenario "Should edit default values from map on #{mappable_factory_name} edit page", :js do
      login_as mappable.author

      visit send(mappable_edit_path, id: mappable.id)
      find(".map_location").click
      click_on("Save changes")
      mappable.reload

      expect(page).to have_css(".map_location")
      expect(page).not_to have_selector(".map_location[data-marker-latitude='#{map_location.latitude}']")
      expect(page).to have_selector(".map_location[data-marker-latitude='#{mappable.map_location.latitude}']")
    end

    scenario "Should edit mappable on #{mappable_factory_name} without change map", :js do
      login_as mappable.author

      visit send(mappable_edit_path, id: mappable.id)
      fill_in "#{mappable_factory_name}_title", with: "New title"
      click_on("Save changes")
      mappable.reload

      expect(page).to have_css(".map_location")
      expect(page).to have_selector(".map_location[data-marker-latitude='#{map_location.latitude}']")
      expect(page).to have_selector(".map_location[data-marker-latitude='#{mappable.map_location.latitude}']")
    end

    scenario "Can not display map on #{mappable_factory_name} edit when remove map marker", :js do
      login_as mappable.author

      visit send(mappable_edit_path, id: mappable.id)
      click_link "Remove map marker"
      click_on "Save changes"

      expect(page).not_to have_css(".map_location")
    end

    scenario "Can not display map on #{mappable_factory_name} edit when feature.map is disabled", :js do
      Setting['feature.map'] = false
      login_as mappable.author

      visit send(mappable_edit_path, id: mappable.id)
      fill_in "#{mappable_factory_name}_title", with: "New title"
      click_on("Save changes")

      expect(page).not_to have_css(".map_location")
    end

  end

  describe "At #{mappable_show_path}" do

    let!(:arguments)    { {} }
    let!(:mappable)     { create(mappable_factory_name.to_s.to_sym) }
    let!(:map_location) { create(:map_location, "#{mappable_factory_name}_map_location".to_sym, "#{mappable_association_name}": mappable) }

    before { set_arguments(arguments, mappable, mappable_path_arguments) }

    scenario "Should display map on #{mappable_factory_name} show page", :js do
      arguments[:id] = mappable.id

      visit send(mappable_show_path, arguments)

      expect(page).to have_css(".map_location")
    end

    scenario "Should not display map on #{mappable_factory_name} show when marker is not defined", :js do
      mappable_without_map = create(mappable_factory_name.to_s.to_sym)
      set_arguments(arguments, mappable_without_map, mappable_path_arguments)
      arguments[:id] = mappable_without_map.id

      visit send(mappable_show_path, arguments)

      expect(page).not_to have_css(".map_location")
    end

    scenario "Should not display map on #{mappable_factory_name} show page when feature.map is disable", :js do
      Setting['feature.map'] = false
      arguments[:id] = mappable.id

      visit send(mappable_show_path, arguments)

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

def validate_latitude_longitude(mappable_factory_name)
  expect(find("##{mappable_factory_name}_map_location_attributes_latitude", visible: false).value).to eq "51.48"
  expect(find("##{mappable_factory_name}_map_location_attributes_longitude", visible: false).value).to eq "0.0"
  expect(mappable.map_location.latitude).to eq 51.48
  expect(mappable.map_location.longitude).to eq 0.0
end

def fill_in_budget_investment_form
  page.select mappable.heading.name_scoped_by_group, from: :budget_investment_heading_id
  fill_in :budget_investment_title, with: "Budget investment title"
  fill_in_ckeditor "budget_investment_description", with: "Budget investment description"
  check :budget_investment_terms_of_service
end

def submit_budget_investment_form
  check :budget_investment_terms_of_service
  click_button 'Create Investment'
end

def set_arguments(arguments, mappable, mappable_path_arguments)
  mappable_path_arguments&.each do |argument_name, path_to_value|
      arguments.merge!("#{argument_name}": mappable.send(path_to_value))
  end
end
