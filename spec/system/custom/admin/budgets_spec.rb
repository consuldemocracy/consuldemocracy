require "rails_helper"

describe "Admin budgets", :admin do
  context "Index" do
    scenario "Filters by phase" do
      create(:budget, :drafting, name: "Unpublished budget")
      create(:budget, :accepting, name: "Accepting budget")
      create(:budget, :selecting, name: "Selecting budget")
      create(:budget, :balloting, name: "Balloting budget")
      create(:budget, :finished, name: "Finished budget")

      visit admin_budgets_path

      expect(page).to have_content "Accepting budget"
      expect(page).to have_content "Selecting budget"
      expect(page).to have_content "Balloting budget"

      within "tr", text: "Unpublished budget" do
        expect(page).to have_content "DRAFT"
      end

      within "tr", text: "Finished budget" do
        expect(page).to have_content "COMPLETED"
      end

      click_link "Finished"

      expect(page).not_to have_content "Unpublished budget"
      expect(page).not_to have_content "Accepting budget"
      expect(page).not_to have_content "Selecting budget"
      expect(page).not_to have_content "Balloting budget"
      expect(page).to have_content "Finished budget"

      click_link "Open"

      expect(page).to have_content "Unpublished budget"
      expect(page).to have_content "Accepting budget"
      expect(page).to have_content "Selecting budget"
      expect(page).to have_content "Balloting budget"
      expect(page).not_to have_content "Finished budget"
    end
  end

  context "Create" do
    scenario "Create a budget with hide money by steps" do
      visit admin_budgets_path
      click_button "Create new budget"
      click_link "Create multiple headings budget"

      fill_in "Name", with: "Multiple headings budget with hide money"
      select "Approval", from: "Final voting style"
      check "Hide money amount for this budget"
      click_button "Continue to groups"

      expect(page).to have_content "New participatory budget created successfully!"
      expect(page).to have_content "There are no groups."

      click_button "Add new group"
      fill_in "Group name", with: "All city"
      click_button "Create new group"

      expect(page).to have_content "Group created successfully!"

      click_button "Add new group"
      fill_in "Group name", with: "District A"
      click_button "Create new group"

      expect(page).to have_content "Group created successfully!"

      within("table") do
        expect(page).to have_content "All city"
        expect(page).to have_content "District A"
      end
      expect(page).not_to have_content "There are no groups."

      click_link "Continue to headings"

      expect(page).to have_content "Showing headings from the All city group."
      expect(page).to have_button "Manage headings from a different group"
      within(".budget-group-switcher") { expect(page).to have_link("District A", visible: :hidden) }

      click_button "Add new heading"
      fill_in "Heading name", with: "All city"
      click_button "Create new heading"

      expect(page).to have_content "Heading created successfully!"
      expect(page).to have_content "All city"
      expect(page).to have_link "Continue to phases"
      expect(page).not_to have_content "There are no headings."
      expect(page).not_to have_content "Money amount"
      expect(page).not_to have_content "€"
    end
  end

  context "Edit" do
    let(:budget) { create(:budget) }

    scenario "Show phases table" do
      travel_to(Date.new(2015, 7, 15)) do
        budget.update!(phase: "selecting")
        budget.phases.valuating.update!(enabled: false)

        visit admin_budget_path(budget)

        expect(page).to have_content "The configuration of these phases is used for information purposes "\
                                     "only. Its function is to define the phases information displayed "\
                                     "on the public page of the participatory budget."
        expect(page).to have_table "Phases", with_cols: [
          [
            "Information (Information)",
            "Accepting projects (Accepting projects)",
            "Reviewing projects (Reviewing projects)",
            "Selecting projects (Selecting projects) Active",
            "Valuating projects (Valuating projects)",
            "Publishing projects prices (Publishing projects prices)",
            "Voting projects (Voting projects)",
            "Reviewing voting (Reviewing voting)",
            "Finished budget (Finished budget)"
          ],
          [
            "2015-07-15 00:00 - 2015-08-14 23:59",
            "2015-08-15 00:00 - 2015-09-14 23:59",
            "2015-09-15 00:00 - 2015-10-14 23:59",
            "2015-10-15 00:00 - 2015-11-14 23:59",
            "2015-11-15 00:00 - 2015-12-14 23:59",
            "2015-12-15 00:00 - 2016-01-14 23:59",
            "2016-01-15 00:00 - 2016-02-14 23:59",
            "2016-02-15 00:00 - 2016-03-14 23:59",
            "2016-03-15 00:00 - 2016-04-14 23:59"
          ],
          [
            "Yes",
            "Yes",
            "Yes",
            "Yes",
            "No",
            "Yes",
            "Yes",
            "Yes",
            "Yes"
          ]
        ]

        within_table "Phases" do
          within "tr", text: "Information" do
            expect(page).to have_link "Edit"
          end
        end

        click_link "Edit budget"

        expect(page).to have_select "Active phase", selected: "Selecting projects"
      end
    end
  end
end
