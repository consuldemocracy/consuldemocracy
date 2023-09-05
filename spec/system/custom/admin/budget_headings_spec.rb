require "rails_helper"

describe "Admin budget headings", :admin do
  let(:budget) { create(:budget, :drafting) }
  let!(:group) { create(:budget_group, budget: budget) }

  context "List of headings in the budget page" do
    scenario "Displaying no headings for group" do
      group.update!(name: "Universities")

      visit admin_budget_path(budget)

      within "section", text: "HEADING GROUPS" do
        expect(page).to have_content "There are no headings in the Universities group."
      end
    end

    scenario "Displaying headings" do
      create(:budget_heading, name: "Laptops", group: group, price: 1000)
      create(:budget_heading, name: "Tablets", group: group, price: 2000)
      create(:budget_heading, name: "Phones", group: group, price: 3000)

      visit admin_budget_path(budget)

      within "section", text: "HEADING GROUPS" do
        within "tbody" do
          expect(page).to have_selector "tr", count: 3

          within("tr", text: "Laptops") { expect(page).to have_content "€1,000" }
          within("tr", text: "Tablets") { expect(page).to have_content "€2,000" }
          within("tr", text: "Phones") { expect(page).to have_content "€3,000" }
        end
      end
    end
  end

  context "New" do
    scenario "Create heading" do
      visit admin_budget_path(budget)

      within "section", text: "HEADING GROUPS" do
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
  end
end
