require "rails_helper"

describe "Admin budget groups", :admin do
  let(:budget) { create(:budget, :drafting) }

  context "List of groups from budget page" do
    scenario "Displaying no groups for budget" do
      visit admin_budget_path(budget)

      within "section", text: "HEADING GROUPS" do
        expect(page.text).to eq "HEADING GROUPS\nAdd group"
      end
    end

    scenario "Displaying groups" do
      above = create(:budget_group, budget: budget, name: "Above ground")
      below = create(:budget_group, budget: budget, name: "Below ground")

      1.times { create(:budget_heading, group: above) }
      2.times { create(:budget_heading, group: below) }

      visit admin_budget_path(budget)

      within "section", text: "HEADING GROUPS" do
        within "section", text: "Above ground" do
          expect(page).to have_css "h4", exact_text: "Above ground"
          expect(page).not_to have_content "Maximum number of headings"
        end

        within "section", text: "Below ground" do
          expect(page).to have_css "h4", exact_text: "Below ground"
          expect(page).to have_content "Maximum number of headings in which a user can select projects 1"
        end
      end
    end
  end

  context "New" do
    scenario "Create group" do
      visit admin_budget_path(budget)
      click_link "Add group"

      fill_in "Group name", with: "All City"

      fill_in "Group name", with: "All City"
      click_button "Create new group"

      expect(page).to have_content "Group created successfully!"

      within "section", text: "HEADING GROUPS" do
        expect(page).to have_css "h4", exact_text: "All City"
      end
    end
  end
end
