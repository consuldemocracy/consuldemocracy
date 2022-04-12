require "rails_helper"

describe "Admin budgets", :admin do
  it_behaves_like "nested imageable",
                  "budget",
                  "new_admin_budgets_wizard_budget_path",
                  {},
                  "imageable_fill_new_valid_budget",
                  "Continue to groups",
                  "New participatory budget created successfully!"

  context "Load" do
    before { create(:budget, slug: "budget_slug") }

    scenario "finds budget by slug" do
      visit edit_admin_budget_path("budget_slug")

      expect(page).to have_content("Edit Participatory budget")
    end
  end

  context "Index" do
    scenario "Displaying no open budgets text" do
      visit admin_budgets_path

      expect(page).to have_content("There are no budgets.")
    end

    scenario "Displaying budgets" do
      budget = create(:budget, :accepting)
      visit admin_budgets_path

      within "tr", text: budget.name do
        expect(page).to have_content "Accepting projects"
        expect(page).to have_content "Pending: No headings yet"
      end
    end

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
        expect(page).to have_content "Draft"
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

    scenario "Filters are properly highlighted" do
      filters_links = { "all" => "All", "open" => "Open", "finished" => "Finished" }

      visit admin_budgets_path

      expect(page).not_to have_link(filters_links.values.first)
      filters_links.keys.drop(1).each { |filter| expect(page).to have_link(filters_links[filter]) }

      filters_links.each do |current_filter, link|
        visit admin_budgets_path(filter: current_filter)

        expect(page).not_to have_link(link)

        (filters_links.keys - [current_filter]).each do |filter|
          expect(page).to have_link(filters_links[filter])
        end
      end
    end
  end

  context "Create" do
    scenario "Create budget - Approval voting with hide money" do
      visit admin_budgets_path
      click_button "Create new budget"
      click_link "Create multiple headings budget"

      expect(page).to have_select("Final voting style", selected: "Knapsack")
      expect(page).not_to have_selector("#budget_hide_money")

      fill_in "Name", with: "Budget hide money"
      select "Approval", from: "Final voting style"
      check "Hide money amount for this budget"
      click_button "Continue to groups"

      expect(page).to have_content "New participatory budget created successfully!"
      expect(page).to have_content "Budget hide money"

      click_link "Go back to edit budget"

      expect(page).to have_select("Final voting style", selected: "Approval")
      expect(page).to have_field "Hide money amount for this budget", checked: true
    end

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
      expect(page).to have_link "Manage headings from the District A group."

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

  context "Publish" do
    let(:budget) { create(:budget, :drafting) }

    scenario "Can preview budget before it is published" do
      visit admin_budget_path(budget)
      click_link "Preview"

      expect(page).to have_current_path budget_path(budget)
    end

    scenario "Can view a budget after it is published" do
      visit admin_budget_path(budget)

      accept_confirm { click_button "Publish budget" }

      expect(page).to have_content "Participatory budget published successfully"
      expect(page).not_to have_content "This participatory budget is in draft mode"
      expect(page).not_to have_button "Publish budget"

      click_link "View"

      expect(page).to have_current_path budget_path(budget)
    end
  end

  context "Destroy" do
    let!(:budget) { create(:budget) }
    let(:heading) { create(:budget_heading, budget: budget) }

    scenario "Destroy a budget without investments" do
      visit admin_budget_path(budget)

      message = "Are you sure? This will delete the budget and all its associated groups and headings. This action cannot be undone."

      accept_confirm(message) { click_button "Delete budget" }

      expect(page).to have_content "Budget deleted successfully"
      expect(page).to have_content "There are no budgets."
    end

    scenario "Try to destroy a budget with investments" do
      create(:budget_investment, heading: heading)

      visit admin_budget_path(budget)

      expect(page).to have_button "Delete budget", disabled: true
      expect(page).to have_content "You cannot delete a budget that has associated investments"
    end

    scenario "Try to destroy a budget with polls" do
      create(:poll, budget: budget)

      visit admin_budget_path(budget)

      expect(page).to have_button "Delete budget", disabled: true
      expect(page).to have_content "You cannot delete a budget that has an associated poll"
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
            "Information",
            "Accepting projects",
            "Reviewing projects",
            "Selecting projects Active",
            "Valuating projects",
            "Publishing projects prices",
            "Voting projects",
            "Reviewing voting"
          ],
          [
            "2015-07-15 00:00 - 2015-08-14 23:59",
            "2015-08-15 00:00 - 2015-09-14 23:59",
            "2015-09-15 00:00 - 2015-10-14 23:59",
            "2015-10-15 00:00 - 2015-11-14 23:59",
            "2015-11-15 00:00 - 2015-12-14 23:59",
            "2015-11-15 00:00 - 2016-01-14 23:59",
            "2016-01-15 00:00 - 2016-02-14 23:59",
            "2016-02-15 00:00 - 2016-03-14 23:59"
          ],
          [
            "Yes",
            "Yes",
            "Yes",
            "Yes",
            "No",
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

    scenario "Show results and stats settings" do
      visit edit_admin_budget_path(budget)

      within_fieldset "Show results and stats" do
        expect(page).to have_field "Show results"
        expect(page).to have_field "Show stats"
        expect(page).to have_field "Show advanced stats"
      end
    end

    scenario "Show CTA link in public site if added" do
      visit edit_admin_budget_path(budget)

      expect(page).to have_content("Main call to action (optional)")

      fill_in "Text on the link", with: "Participate now"
      fill_in "The link takes you to (add a link)", with: "https://consulproject.org"
      click_button "Update Budget"

      expect(page).to have_content "Participatory budget updated successfully"

      visit budgets_path
      expect(page).to have_link("Participate now", href: "https://consulproject.org")
    end

    scenario "Changing name for current locale will update the slug if budget is in draft phase" do
      budget.update!(published: false, name: "Old English Name")

      visit edit_admin_budget_path(budget)

      select "Español", from: :add_language
      fill_in "Name", with: "Spanish name"
      click_button "Update Budget"

      expect(page).to have_content "Participatory budget updated successfully"

      visit budget_path(id: "old-english-name")

      expect(page).to have_content "Old English Name"

      visit edit_admin_budget_path(budget)

      select "English", from: :select_language
      fill_in "Name", with: "New English Name"
      click_button "Update Budget"

      expect(page).to have_content "Participatory budget updated successfully"

      visit budget_path(id: "new-english-name")

      expect(page).to have_content "New English Name"
    end

    scenario "Hide money active" do
      budget_hide_money = create(:budget, :approval, :hide_money)
      group = create(:budget_group, budget: budget_hide_money)
      heading = create(:budget_heading, group: group)
      heading_2 = create(:budget_heading, group: group)

      visit admin_budget_path(budget_hide_money)

      expect(page).to have_content heading.name
      expect(page).to have_content heading_2.name
      expect(page).not_to have_content "Money amount"
      expect(page).not_to have_content "€"

      visit edit_admin_budget_path(budget_hide_money)

      expect(page).to have_field "Hide money amount for this budget", checked: true
      expect(page).to have_select("Final voting style", selected: "Approval")
    end

    scenario "Change voting style uncheck hide money" do
      budget_hide_money = create(:budget, :approval, :hide_money)
      hide_money_help_text = "If this option is checked, all fields showing the amount of money "\
                             "will be hidden throughout the process."

      visit edit_admin_budget_path(budget_hide_money)

      expect(page).to have_field "Hide money amount for this budget", checked: true
      expect(page).to have_content hide_money_help_text

      select "Knapsack", from: "Final voting style"

      expect(page).not_to have_field "Hide money amount for this budget"
      expect(page).not_to have_content hide_money_help_text

      select "Approval", from: "Final voting style"

      expect(page).to have_field "Hide money amount for this budget", checked: false
      expect(page).to have_content hide_money_help_text
    end

    scenario "Edit knapsack budget do not show hide money info" do
      budget = create(:budget, :knapsack)
      hide_money_help_text = "If this option is checked, all fields showing the amount of money "\
                             "will be hidden throughout the process."

      visit edit_admin_budget_path(budget)

      expect(page).not_to have_field "Hide money amount for this budget"
      expect(page).not_to have_content hide_money_help_text

      select "Approval", from: "Final voting style"

      expect(page).to have_field "Hide money amount for this budget", checked: false
      expect(page).to have_content hide_money_help_text
    end

    scenario "Edit approval budget show hide money info" do
      budget = create(:budget, :approval)
      hide_money_help_text = "If this option is checked, all fields showing the amount of money "\
                             "will be hidden throughout the process."

      visit edit_admin_budget_path(budget)

      expect(page).to have_field "Hide money amount for this budget", checked: false
      expect(page).to have_content hide_money_help_text

      select "Knapsack", from: "Final voting style"

      expect(page).not_to have_field "Hide money amount for this budget"
      expect(page).not_to have_content hide_money_help_text
    end
  end

  context "Update" do
    scenario "Update budget" do
      budget = create(:budget)

      visit edit_admin_budget_path(budget)

      fill_in "Name", with: "More trees on the streets"
      click_button "Update Budget"

      expect(page).to have_content "Participatory budget updated successfully"
      expect(page).to have_content("More trees on the streets")
      expect(page).to have_current_path(admin_budget_path(budget))
    end

    scenario "Deselect all selected staff" do
      admin = Administrator.first
      valuator = create(:valuator)

      budget = create(:budget, administrators: [admin], valuators: [valuator])

      visit edit_admin_budget_path(budget)
      click_link "1 administrator selected"
      uncheck admin.name

      expect(page).to have_link "Select administrators"

      click_link "1 valuator selected"
      uncheck valuator.name

      expect(page).to have_link "Select valuators"

      click_button "Update Budget"
      visit edit_admin_budget_path(budget)

      expect(page).to have_link "Select administrators"
      expect(page).to have_link "Select valuators"
    end
  end

  context "Calculate Budget's Winner Investments" do
    scenario "For a Budget in reviewing balloting" do
      budget = create(:budget, :reviewing_ballots)
      heading = create(:budget_heading, budget: budget, price: 4)
      unselected = create(:budget_investment, :unselected, heading: heading, price: 1,
                                                           ballot_lines_count: 3)
      winner = create(:budget_investment, :selected, heading: heading, price: 3,
                                                   ballot_lines_count: 2)
      selected = create(:budget_investment, :selected, heading: heading, price: 2, ballot_lines_count: 1)

      visit admin_budget_path(budget)

      expect(page).not_to have_content "See results"

      click_button "Calculate Winner Investments"

      expect(page).to have_content "Winners being calculated, it may take a minute."
      expect(page).to have_content winner.title
      expect(page).not_to have_content unselected.title
      expect(page).not_to have_content selected.title

      visit admin_budget_path(budget)

      expect(page).not_to have_link "See results"

      click_link "Edit budget"
      select "Finished budget", from: "Active phase"
      check "Show results"
      click_button "Update Budget"

      expect(page).to have_content "Participatory budget updated successfully"
      expect(page).to have_link "See results"
    end

    scenario "Recalculate for a budget in reviewing ballots" do
      budget = create(:budget, :reviewing_ballots)
      create(:budget_investment, :winner, budget: budget)

      visit admin_budget_budget_investments_path(budget)
      click_link "Advanced filters"
      check "Winners"
      click_button "Filter"

      expect(page).to have_content "Recalculate Winner Investments"
      expect(page).not_to have_content "Calculate Winner Investments"
    end
  end
end
