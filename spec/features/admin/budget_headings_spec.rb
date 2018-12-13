require 'rails_helper'

feature "Admin budget headings" do

  let(:budget) { create(:budget, phase: "drafting") }
  let(:group) { create(:budget_group, budget: budget) }

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  context "Feature flag" do

    background do
      Setting["feature.budgets"] = nil
    end

    after do
      Setting["feature.budgets"] = true
    end

    scenario "Disabled with a feature flag" do
      expect { visit admin_budget_group_headings_path(budget, group) }.to raise_exception(FeatureFlags::FeatureDisabled)
    end

  end

  context "Index" do

    scenario "Displaying no headings for group" do
      visit admin_budget_group_headings_path(budget, group)

      expect(page).to have_content "No headings created yet. Each user will be able to vote in only one heading per group."
    end

    scenario "Displaying headings" do
      heading1 = create(:budget_heading, group: group, price: 1000, allow_custom_content: true)
      heading2 = create(:budget_heading, group: group, price: 2000, population: 10000)
      heading3 = create(:budget_heading, group: group, price: 3000, population: 10000)

      visit admin_budget_group_headings_path(budget, group)
      expect(page).to have_content "There are 3 headings"

      within "#budget_heading_#{heading1.id}" do
        expect(page).to have_content(heading1.name)
        expect(page).to have_content "€1,000"
        expect(page).not_to have_content "10000"
        expect(page).to have_content "Yes"
        expect(page).to have_link "Edit", href: edit_admin_budget_group_heading_path(budget, group, heading1)
        expect(page).to have_link "Delete", href: admin_budget_group_heading_path(budget, group, heading1)
      end

      within "#budget_heading_#{heading2.id}" do
        expect(page).to have_content(heading2.name)
        expect(page).to have_content "€2,000"
        expect(page).to have_content "10000"
        expect(page).to have_content "No"
        expect(page).to have_link "Edit", href: edit_admin_budget_group_heading_path(budget, group, heading2)
        expect(page).to have_link "Delete", href: admin_budget_group_heading_path(budget, group, heading2)
      end

      within "#budget_heading_#{heading3.id}" do
        expect(page).to have_content(heading3.name)
        expect(page).to have_content "€3,000"
        expect(page).to have_content "10000"
        expect(page).to have_content "No"
        expect(page).to have_link "Edit", href: edit_admin_budget_group_heading_path(budget, group, heading3)
        expect(page).to have_link "Delete", href: admin_budget_group_heading_path(budget, group, heading3)
      end
    end

    scenario "Delete a heading without investments" do
      heading = create(:budget_heading, group: group)

      visit admin_budget_group_headings_path(budget, group)
      within("#budget_heading_#{heading.id}") { click_link "Delete" }

      expect(page).to have_content "Heading deleted successfully"
      expect(page).not_to have_selector "#budget_heading_#{heading.id}"
    end

    scenario "Try to delete a heading with investments" do
      heading = create(:budget_heading, group: group)
      investment = create(:budget_investment, heading: heading)

      visit admin_budget_group_headings_path(budget, group)
      within("#budget_heading_#{heading.id}") { click_link "Delete" }

      expect(page).to have_content "You cannot destroy a Heading that has associated investments"
      expect(page).to have_selector "#budget_heading_#{heading.id}"
    end

  end

  context "New" do

    scenario "Create heading" do
      visit admin_budget_group_headings_path(budget, group)
      click_link "Create new heading"

      fill_in "Heading name", with: "All City"
      fill_in "Amount", with: "1000"
      fill_in "Population (optional)", with: "10000"
      check "Allow content block"

      click_button "Create new heading"

      expect(page).to have_content "Heading created successfully!"
      expect(page).to have_link "All City"
      expect(page).to have_content "€1,000"
      expect(page).to have_content "10000"
      expect(page).to have_content "Yes"
    end

    scenario "Heading name is mandatory" do
      visit new_admin_budget_group_heading_path(budget, group)
      click_button "Create new heading"

      expect(page).not_to have_content "Heading created successfully!"
      expect(page).to have_css("label.error", text: "Heading name")
      expect(page).to have_content "can't be blank"
    end

    scenario "Heading amount is mandatory" do
      visit new_admin_budget_group_heading_path(budget, group)
      click_button "Create new heading"

      expect(page).not_to have_content "Heading created successfully!"
      expect(page).to have_css("label.error", text: "Amount")
      expect(page).to have_content "can't be blank"
    end

  end

  context "Edit" do

    scenario "Show heading information" do
      heading = create(:budget_heading, group: group)

      visit admin_budget_group_headings_path(budget, group)
      within("#budget_heading_#{heading.id}") { click_link "Edit" }

      expect(page).to have_field "Heading name", with: heading.name
      expect(page).to have_field "Amount", with: heading.price
      expect(page).to have_field "Population (optional)", with: heading.population
      expect(page).to have_field "Longitude", with: heading.longitude
      expect(page).to have_field "Latitude", with: heading.latitude
      expect(find_field("Allow content block")).not_to be_checked
    end

  end

  context "Update" do
    let(:heading) { create(:budget_heading,
                            group: group,
                            name: "All City",
                            price: 1000,
                            population: 10000,
                            longitude: 20.50,
                            latitude: -10.50,
                            allow_custom_content: true) }

    scenario "Updates group" do
      visit edit_admin_budget_group_heading_path(budget, group, heading)

      expect(page).to have_field "Heading name", with: "All City"
      expect(page).to have_field "Amount", with: 1000
      expect(page).to have_field "Population (optional)", with: 10000
      expect(page).to have_field "Longitude", with: 20.50
      expect(page).to have_field "Latitude", with: -10.50
      expect(find_field("Allow content block")).to be_checked

      fill_in "Heading name", with: "Districts"
      fill_in "Amount", with: "2000"
      fill_in "Population (optional)", with: "20000"
      fill_in "Longitude", with: "-40.47"
      fill_in "Latitude", with: "25.25"
      uncheck "Allow content block"
      click_button "Edit heading"

      expect(page).to have_content "Heading updated successfully"

      visit edit_admin_budget_group_heading_path(budget, group, heading)
      expect(page).to have_field "Heading name", with: "Districts"
      expect(page).to have_field "Amount", with: 2000
      expect(page).to have_field "Population (optional)", with: 20000
      expect(page).to have_field "Longitude", with: -40.47
      expect(page).to have_field "Latitude", with: 25.25
      expect(find_field("Allow content block")).not_to be_checked
    end

    scenario "Heading name is already used" do
      create(:budget_heading, group: group, name: "Districts")

      visit edit_admin_budget_group_heading_path(budget, group, heading)
      expect(page).to have_field "Heading name", with: "All City"

      fill_in "Heading name", with: "Districts"
      click_button "Edit heading"

      expect(page).not_to have_content "Heading updated successfully"
      expect(page).to have_css("label.error", text: "Heading name")
      expect(page).to have_content "has already been taken"
    end

  end
end
