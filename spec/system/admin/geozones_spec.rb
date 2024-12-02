require "rails_helper"

describe "Admin geozones", :admin do
  scenario "Show list of geozones" do
    chamberi = create(:geozone, name: "Chamberí")
    retiro = create(:geozone, name: "Retiro")

    visit admin_geozones_path

    expect(page).to have_content(chamberi.name)
    expect(page).to have_content(retiro.name)
  end

  scenario "Create new geozone" do
    visit admin_root_path

    within("#side_menu") do
      click_button "Settings"
      click_link "Geozones"
    end

    click_link "Create geozone"

    fill_in "geozone_name", with: "Fancy District"
    fill_in "geozone_external_code", with: 123
    fill_in "geozone_census_code", with: 44

    click_button "Save changes"

    expect(page).to have_content "Geozone created successfully"
    expect(page).to have_content "Fancy District"

    visit admin_geozones_path

    expect(page).to have_content "Fancy District"
  end

  scenario "Edit geozone with no associated elements" do
    geozone = create(:geozone, name: "Edit me!", census_code: "012")

    visit admin_geozones_path

    within("#geozone_#{geozone.id}") { click_link "Edit" }

    fill_in "geozone_name", with: "New geozone name"
    fill_in "geozone_census_code", with: "333"

    click_button "Save changes"

    expect(page).to have_content "Geozone updated successfully"

    within("#geozone_#{geozone.id}") do
      expect(page).to have_content "New geozone name"
      expect(page).to have_content "333"
    end
  end

  scenario "Edit geozone with associated elements" do
    geozone = create(:geozone, name: "Edit me!")
    create(:proposal, title: "Proposal with geozone", geozone: geozone)

    visit admin_geozones_path

    within("#geozone_#{geozone.id}") { click_link "Edit" }

    fill_in "geozone_name", with: "New geozone name"

    click_button "Save changes"

    expect(page).to have_content "Geozone updated successfully"

    within("#geozone_#{geozone.id}") do
      expect(page).to have_content "New geozone name"
    end
  end

  scenario "Delete geozone with no associated elements" do
    geozone = create(:geozone, name: "Delete me!")

    visit admin_geozones_path

    within("#geozone_#{geozone.id}") do
      accept_confirm("Are you sure? This action will delete \"Delete me!\" and can't be undone.") do
        click_button "Delete"
      end
    end

    expect(page).to have_content "Geozone successfully deleted"
    expect(page).not_to have_content("Delete me!")
  end

  scenario "Delete geozone with associated element" do
    geozone = create(:geozone, name: "Delete me!")
    create(:proposal, geozone: geozone)

    visit admin_geozones_path

    within("#geozone_#{geozone.id}") do
      accept_confirm("Are you sure? This action will delete \"Delete me!\" and can't be undone.") do
        click_button "Delete"
      end
    end

    expect(page).to have_content "This geozone can't be deleted since there are elements attached to it"

    within("#geozone_#{geozone.id}") do
      expect(page).to have_content "Delete me!"
    end
  end

  scenario "Show polygons when a heading is associated with a geozone" do
    Setting["feature.map"] = true
    geojson = <<~JSON
      {
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "coordinates": [[[-0.1, 51.5], [-0.2, 51.4], [-0.3, 51.6], [-0.1, 51.5]]]
        }
      }
    JSON

    geozone = create(:geozone, name: "Polygon me!")
    budget = create(:budget)
    group = create(:budget_group, budget: budget)
    heading = create(:budget_heading, name: "Area 51", group: group)

    visit edit_admin_geozone_path(geozone)
    fill_in "GeoJSON data (optional)", with: geojson
    fill_in "Color (optional)", with: "#f5c211"
    click_button "Save changes"

    expect(page).to have_content "Geozone updated successfully"

    visit edit_admin_budget_group_heading_path(budget, group, heading)
    select "Polygon me!", from: "Scope of operation"

    click_button "Save heading"

    expect(page).to have_content "Heading updated successfully"

    visit budget_path(budget)

    expect(page).to have_css ".map-polygon[fill='#f5c211']"
    within(".map-location") { expect(page).not_to have_link "Area 51" }

    find(".map-polygon").click

    within ".map-location" do
      expect(page).to have_link "Area 51", href: budget_investments_path(budget, heading_id: heading.id)
    end
  end

  scenario "Show polygons on geozone admin view" do
    Setting["feature.map"] = true
    geojson = <<~JSON
      {
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "coordinates": [[[-0.1, 51.5], [-0.2, 51.4], [-0.3, 51.6], [-0.1, 51.5]]]
        }
      }
    JSON

    geozone = create(:geozone, name: "Polygon me!", geojson: geojson)

    visit admin_geozones_path

    find(".map-polygon").click

    within ".map-location" do
      expect(page).to have_link "Polygon me!", href: edit_admin_geozone_path(geozone)
    end
  end

  scenario "overwrites geozone data with features data" do
    geojson = <<~JSON
      {
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "coordinates": [[[-0.1, 51.5], [-0.2, 51.5], [-0.2, 51.6], [-0.1, 51.6], [-0.1, 51.5]]]
        },
        "properties": {
          "color": "#ff5733",
          "headings": ["Zone 1", "Test zone"]
        }
      }
    JSON

    create(:geozone, color: "#001122", geojson: geojson)

    visit admin_geozones_path

    expect(page).to have_css ".map-polygon[fill='#ff5733']"
    expect(page).not_to have_css ".map-polygon[fill='#001122']"
    expect(page).not_to have_content "Zone 1"
    expect(page).not_to have_content "Test zone"

    find(".map-polygon").click

    expect(page).to have_content "Zone 1\nTest zone"
  end

  scenario "includes a control to select which geozones to display" do
    north = <<~JSON
      {
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "coordinates": [[[-0.1, 51.5], [-0.2, 51.5], [-0.2, 51.6], [-0.1, 51.6], [-0.1, 51.5]]]
        },
        "properties": {}
      }
    JSON

    south = <<~JSON
      {
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "coordinates": [[[-0.1, 51.45], [-0.2, 51.45], [-0.2, 51.35], [-0.1, 51.35], [-0.1, 51.45]]]
        },
        "properties": {}
      }
    JSON

    create(:geozone, name: "North", geojson: north)
    create(:geozone, name: "South", geojson: south)

    visit admin_geozones_path

    within(".map-location") do
      expect(page).to have_css ".map-polygon", count: 2

      find(".leaflet-control-layers").click
      uncheck "South"

      expect(page).to have_css ".map-polygon", count: 1

      find(".map-polygon").click

      expect(page).to have_content "North"
      expect(page).not_to have_content "South"
    end
  end
end
