require "rails_helper"

describe "Admin budget headings", :admin do
  let(:budget) { create(:budget, :drafting) }
  let!(:group) { create(:budget_group, budget: budget) }

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
  end

  context "List of headings in the budget page" do
    scenario "Displaying no headings for group" do
      group.update!(name: "Universities")

      visit admin_budget_path(budget)

      within "section", text: "Heading groups" do
        expect(page).to have_content "There are no headings in the Universities group."
      end
    end

    scenario "Displaying headings" do
      create(:budget_heading, name: "Laptops", group: group, price: 1000)
      create(:budget_heading, name: "Tablets", group: group, price: 2000)
      create(:budget_heading, name: "Phones", group: group, price: 3000)

      visit admin_budget_path(budget)

      within "section", text: "Heading groups" do
        within "tbody" do
          expect(page).to have_selector "tr", count: 3

          within("tr", text: "Laptops") { expect(page).to have_content "€1,000" }
          within("tr", text: "Tablets") { expect(page).to have_content "€2,000" }
          within("tr", text: "Phones") { expect(page).to have_content "€3,000" }
        end
      end
    end

    scenario "Delete a heading without investments" do
      create(:budget_heading, group: group, name: "Lemuria")

      visit admin_budget_path(budget)

      within("tr", text: "Lemuria") do
        accept_confirm("Are you sure? This action will delete \"Lemuria\" and can't be undone.") do
          click_button "Delete"
        end
      end

      expect(page).to have_content "Heading deleted successfully"
      expect(page).not_to have_content "Lemuria"
    end

    scenario "Try to delete a heading with investments" do
      heading = create(:budget_heading, group: group, name: "Atlantis")
      create(:budget_investment, heading: heading)

      visit admin_budget_path(budget)

      within(".heading", text: "Atlantis") do
        accept_confirm("Are you sure? This action will delete \"Atlantis\" and can't be undone.") do
          click_button "Delete"
        end
      end

      expect(page).to have_content "You cannot delete a Heading that has associated investments"
      expect(page).to have_content "Atlantis"
    end
  end

  context "New" do
    scenario "Create heading" do
      visit admin_budget_path(budget)

      within "section", text: "Heading groups" do
        within("section", text: group.name) { click_link "Add heading" }
      end

      fill_in "Heading name", with: "All City"
      fill_in "Money amount", with: "1000"
      fill_in "Population (optional)", with: "10000"
      check "Allow content block"

      click_button "Create new heading"

      expect(page).to have_content "Heading created successfully!"

      within "tr", text: "All City" do
        expect(page).to have_content "€1,000"

        click_link "Edit"
      end

      expect(page).to have_field "Population (optional)", with: "10000"
      expect(page).to have_field "Allow content block", checked: true
    end

    scenario "Heading name is mandatory" do
      visit new_admin_budget_group_heading_path(budget, group)
      click_button "Create new heading"

      expect(page).not_to have_content "Heading created successfully!"
      expect(page).to have_css(".is-invalid-label", text: "Heading name")
      expect(page).to have_content "can't be blank"
    end

    scenario "Heading amount is mandatory" do
      visit new_admin_budget_group_heading_path(budget, group)
      click_button "Create new heading"

      expect(page).not_to have_content "Heading created successfully!"
      expect(page).to have_css(".is-invalid-label", text: "Money amount")
      expect(page).to have_content "can't be blank"
    end

    scenario "Heading money field is hidden if hide money is true" do
      budget_hide_money = create(:budget, :hide_money)
      group = create(:budget_group, budget: budget_hide_money)

      visit new_admin_budget_group_heading_path(budget_hide_money, group)

      fill_in "Heading name", with: "Heading without money"
      click_button "Create new heading"

      expect(page).to have_content "Heading created successfully!"
      expect(page).not_to have_content "Money amount"
    end

    describe "Max votes is optional" do
      scenario "do no show max_ballot_lines field for knapsack budgets" do
        visit new_admin_budget_group_heading_path(budget, group)

        expect(page).not_to have_field "Votes allowed"
      end

      scenario "create heading with max_ballot_lines for appoval budgets" do
        budget.update!(voting_style: "approval")

        visit new_admin_budget_group_heading_path(budget, group)

        expect(page).to have_field "Votes allowed", with: 1

        fill_in "Heading name", with: "All City"
        fill_in "Money amount", with: "1000"
        fill_in "Votes allowed", with: 14
        click_button "Create new heading"

        expect(page).to have_content "Heading created successfully!"
        within("tr", text: "All City") { expect(page).to have_content 14 }
      end
    end
  end

  context "Edit" do
    scenario "Show heading information" do
      heading = create(:budget_heading, group: group)

      visit admin_budget_path(budget)
      within("#budget_heading_#{heading.id}") { click_link "Edit" }

      expect(page).to have_field "Heading name", with: heading.name
      expect(page).to have_field "Money amount", with: heading.price
      expect(page).to have_field "Population (optional)", with: heading.population
      expect(page).to have_field "Longitude (optional)", with: heading.longitude
      expect(page).to have_field "Latitude (optional)", with: heading.latitude
      expect(find_field("Allow content block")).not_to be_checked
    end

    scenario "Changing name for current locale will update the slug if budget is in draft phase" do
      heading = create(:budget_heading, group: group, name: "Old English Name")

      visit edit_admin_budget_group_heading_path(budget, group, heading)

      select "Español", from: :add_language
      fill_in "Heading name", with: "Spanish name"
      click_button "Save heading"

      expect(page).to have_content "Heading updated successfully"

      visit budget_investments_path(budget, heading_id: "old-english-name")

      expect(page).to have_content "Old English Name"

      visit edit_admin_budget_group_heading_path(budget, group, heading)

      select "English", from: :select_language
      fill_in "Heading name", with: "New English Name"
      click_button "Save heading"

      expect(page).to have_content "Heading updated successfully"

      visit budget_investments_path(budget, heading_id: "new-english-name")

      expect(page).to have_content "New English Name"
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
