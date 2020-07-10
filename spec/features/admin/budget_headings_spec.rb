require "rails_helper"

describe "Admin budget headings" do
  let(:budget) { create(:budget, :drafting) }
  let!(:group) { create(:budget_group, budget: budget) }

  before do
    admin = create(:administrator)
    login_as(admin.user)
  end

  context "Feature flag" do
    before do
      Setting["process.budgets"] = nil
    end

    scenario "Disabled with a feature flag" do
      expect do
        visit admin_budget_group_headings_path(budget, group)
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  context "Load" do
    let!(:budget)  { create(:budget, slug: "budget_slug") }
    let!(:group)   { create(:budget_group, slug: "group_slug", budget: budget) }
    let!(:heading) { create(:budget_heading, slug: "heading_slug", group: group) }

    scenario "finds budget, group and heading by slug" do
      visit edit_admin_budget_group_heading_path("budget_slug", "group_slug", "heading_slug")
      expect(page).to have_content(budget.name)
      expect(page).to have_content(group.name)
      expect(page).to have_field "Heading name", with: heading.name
    end

    scenario "raises an error if budget slug is not found" do
      expect do
        visit edit_admin_budget_group_heading_path("wrong_budget", group, heading)
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "raises an error if budget id is not found" do
      expect do
        visit edit_admin_budget_group_heading_path(0, group, heading)
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "raises an error if group slug is not found" do
      expect do
        visit edit_admin_budget_group_heading_path(budget, "wrong_group", heading)
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "raises an error if group id is not found" do
      expect do
        visit edit_admin_budget_group_heading_path(budget, 0, heading)
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "raises an error if heading slug is not found" do
      expect do
        visit edit_admin_budget_group_heading_path(budget, group, "wrong_heading")
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "raises an error if heading id is not found" do
      expect do
        visit edit_admin_budget_group_heading_path(budget, group, 0)
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context "List of headings from budget edit view" do
    scenario "Displaying no headings for group" do
      visit admin_budget_path(budget)

      within "#group_#{group.id}" do
        within("tbody") { expect(page).not_to have_selector "tr" }
      end
    end

    scenario "Displaying headings" do
      heading1 = create(:budget_heading, group: group, price: 1000, allow_custom_content: true)
      heading2 = create(:budget_heading, group: group, price: 2000, population: 10000)
      heading3 = create(:budget_heading, group: group, price: 3000, population: 20000)

      visit admin_budget_path(budget)

      within "#group_#{group.id}" do
        within "tbody" do
          expect(page).to have_selector "tr", count: 3

          within "#heading_#{heading1.id}" do
            expect(page).to have_content(heading1.name)
            expect(page).to have_content "€1,000"
            expect(page).not_to have_content "10000"
            expect(page).to have_content "Yes"
          end

          within "#heading_#{heading2.id}" do
            expect(page).to have_content(heading2.name)
            expect(page).to have_content "€2,000"
            expect(page).to have_content "10000"
            expect(page).to have_content "No"
          end

          within "#heading_#{heading3.id}" do
            expect(page).to have_content(heading3.name)
            expect(page).to have_content "€3,000"
            expect(page).to have_content "20000"
            expect(page).to have_content "No"
          end
        end
      end
    end

    scenario "Delete a heading without investments" do
      heading = create(:budget_heading, group: group)

      visit admin_budget_path(budget)

      expect(page).to have_selector "#heading_#{heading.id}"
      click_link "delete_heading_#{heading.id}"

      expect(page).to have_content "Heading deleted successfully"
      expect(page).not_to have_selector "#heading_#{heading.id}"
    end

    scenario "Try to delete a heading with investments" do
      heading = create(:budget_heading, group: group, name: "Atlantis")
      create(:budget_investment, heading: heading)

      visit admin_budget_path(budget)

      expect(page).to have_selector "#heading_#{heading.id}"
      click_link "delete_heading_#{heading.id}"

      expect(page).not_to have_content "Heading deleted successfully"
      expect(page).to have_selector "#heading_#{heading.id}"
    end
  end

  context "New" do
    scenario "Create heading" do
      visit admin_budget_path(budget)
      within("#group_#{group.id}") { click_link "Add heading" }

      fill_in "Heading name", with: "All City"
      fill_in "Money amount", with: "1000"
      fill_in "Population (optional)", with: "10000"
      check "Allow content block"

      click_button "Create new heading"

      expect(page).to have_content "Heading created successfully!"

      heading = Budget::Heading.last
      within "#heading_#{heading.id}" do
        expect(page).to have_content "All City"
        expect(page).to have_content "€1,000"
        expect(page).to have_content "10000"
        expect(page).to have_content "Yes"
      end
    end

    scenario "Heading name is mandatory" do
      visit new_admin_budget_group_heading_path(budget, group)
      click_button "Create new heading"

      expect(page).not_to have_content "Heading created successfully!"
      expect(page).to have_css(".is-invalid-label", text: "Heading name")
      expect(page).to have_content "can't be blank"
    end

    scenario "Heading money amount is mandatory" do
      visit new_admin_budget_group_heading_path(budget, group)
      click_button "Create new heading"

      expect(page).not_to have_content "Heading created successfully!"
      expect(page).to have_css(".is-invalid-label", text: "Money amount")
      expect(page).to have_content "can't be blank"
    end
  end

  context "Edit" do
    scenario "Show heading information" do
      heading = create(:budget_heading, group: group)

      visit admin_budget_path(budget)
      click_link "edit_heading_#{heading.id}"

      expect(page).to have_field "Heading name", with: heading.name
      expect(page).to have_field "Money amount", with: heading.price
      expect(page).to have_field "Population (optional)", with: heading.population
      expect(page).to have_field "Longitude (optional)", with: heading.longitude
      expect(page).to have_field "Latitude (optional)", with: heading.latitude
      expect(find_field("Allow content block")).not_to be_checked
    end

    scenario "Changing name for current locale will update the slug if budget is in draft phase", :js do
      heading = create(:budget_heading, group: group)
      old_slug = heading.slug

      visit edit_admin_budget_group_heading_path(budget, group, heading)

      select "Español", from: :add_language
      fill_in "Heading name", with: "Spanish name"
      click_button "Save heading"

      expect(page).to have_content "Heading updated successfully"
      expect(heading.reload.slug).to eq old_slug

      visit edit_admin_budget_group_heading_path(budget, group, heading)

      select "English", from: :select_language
      fill_in "Heading name", with: "New English Name"
      click_button "Save heading"

      expect(page).to have_content "Heading updated successfully"
      expect(heading.reload.slug).not_to eq old_slug
      expect(heading.slug).to eq "new-english-name"
    end
  end

  context "Update" do
    let(:heading) do
      create(:budget_heading,
             group: group,
             name: "All City",
             price: 1000,
             population: 10000,
             longitude: 20.50,
             latitude: -10.50,
             allow_custom_content: true)
    end

    scenario "Updates group" do
      visit edit_admin_budget_group_heading_path(budget, group, heading)

      expect(page).to have_field "Heading name", with: "All City"
      expect(page).to have_field "Money amount", with: 1000
      expect(page).to have_field "Population (optional)", with: 10000
      expect(page).to have_field "Longitude (optional)", with: 20.50
      expect(page).to have_field "Latitude (optional)", with: -10.50
      expect(find_field("Allow content block")).to be_checked

      fill_in "Heading name", with: "Districts"
      fill_in "Money amount", with: "2000"
      fill_in "Population (optional)", with: "20000"
      fill_in "Longitude (optional)", with: "-40.47"
      fill_in "Latitude (optional)", with: "25.25"
      uncheck "Allow content block"
      click_button "Save heading"

      expect(page).to have_content "Heading updated successfully"

      visit edit_admin_budget_group_heading_path(budget, group, heading)
      expect(page).to have_field "Heading name", with: "Districts"
      expect(page).to have_field "Money amount", with: 2000
      expect(page).to have_field "Population (optional)", with: 20000
      expect(page).to have_field "Longitude (optional)", with: -40.47
      expect(page).to have_field "Latitude (optional)", with: 25.25
      expect(find_field("Allow content block")).not_to be_checked
    end

    scenario "Heading name is already used" do
      create(:budget_heading, group: group, name: "Districts")

      visit edit_admin_budget_group_heading_path(budget, group, heading)
      expect(page).to have_field "Heading name", with: "All City"

      fill_in "Heading name", with: "Districts"
      click_button "Save heading"

      expect(page).not_to have_content "Heading updated successfully"
      expect(page).to have_css(".is-invalid-label", text: "Heading name")
      expect(page).to have_css("small.form-error", text: "has already been taken")
    end
  end
end
