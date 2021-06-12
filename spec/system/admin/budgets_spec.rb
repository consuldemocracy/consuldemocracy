require "rails_helper"

describe "Admin budgets", :admin do
  it_behaves_like "nested imageable",
                  "budget",
                  "new_admin_budget_path",
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

      expect(page).to have_content budget.name
      expect(page).to have_content "Accepting projects"
    end

    scenario "Displaying budget information" do
      budget_single = create(:budget, :accepting)
      budget_multiple = create(:budget, :balloting)
      budget_draft = create(:budget, :drafting)
      budget_finised = create(:budget, :finished)

      create(:budget_heading, budget: budget_single)
      create(:budget_heading, budget: budget_multiple)
      create(:budget_heading, budget: budget_multiple)

      visit admin_budgets_path

      within "#budget_#{budget_single.id}" do
        expect(page).to have_content(budget_single.name)
        expect(page).to have_content("Accepting projects")
        expect(page).to have_content("Single heading")
        expect(page).to have_content("(2/9)")
        expect(page).to have_content("9 months")
        expect(page).to have_content("#{budget_single.phases.first.starts_at.to_date} 00:00:00 - "\
                                     "#{budget_single.phases.last.ends_at.to_date - 1} 23:59:59")
      end

      within "#budget_#{budget_multiple.id}" do
        expect(page).to have_content(budget_multiple.name)
        expect(page).to have_content("Voting projects")
        expect(page).to have_content("Multiple headings")
        expect(page).to have_content("(7/9)")
        expect(page).to have_content("9 months")
        expect(page).to have_content("#{budget_multiple.phases.first.starts_at.to_date} 00:00:00 - "\
                                     "#{budget_multiple.phases.last.ends_at.to_date - 1} 23:59:59")
      end

      within "#budget_#{budget_draft.id}" do
        expect(page).to have_content(budget_draft.name)
        expect(page).to have_content("DRAFT")
      end

      within "#budget_#{budget_finised.id}" do
        expect(page).to have_content(budget_finised.name)
        expect(page).to have_content("COMPLETED")
      end
    end

    scenario "Displaying budget current phase information for non common cases" do
      budget_without_enabled_phases = create(:budget, :accepting)
      budget_without_enabled_phases.phases.each { |phase| phase.update!(enabled: false) }
      budget_in_a_not_enabled_phase = create(:budget, :accepting)
      budget_in_a_not_enabled_phase.phases.accepting.update!(enabled: false)

      visit admin_budgets_path

      within "#budget_#{budget_without_enabled_phases.id}" do
        expect(page).to have_content("(0/0)")
      end

      within "#budget_#{budget_in_a_not_enabled_phase.id}" do
        expect(page).to have_content("(0/8)")
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
      expect(page).to have_content "Unpublished budget"
      expect(page).to have_content "Finished budget"

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

    scenario "Delete budget from index" do
      budget = create(:budget)
      visit admin_budgets_path

      within "#budget_#{budget.id}" do
        click_link "Delete budget"
      end

      page.driver.browser.switch_to.alert do
        expect(page).to have_content "Are you sure? This action will delete the budget '#{budget.name}' "\
                                      "and can't be undone."
      end

      accept_confirm

      expect(page).to have_content("Budget deleted successfully")
      expect(page).to have_content("There are no budgets.")
      expect(page).not_to have_content budget.name
    end
  end

  context "New" do
    scenario "Create budget - Knapsack voting (default)" do
      visit admin_budgets_path
      click_button "Create new budget"
      click_link "Create multiple headings budget"

      fill_in "Name", with: "M30 - Summer campaign"
      click_button "Continue to groups"

      expect(page).to have_content "New participatory budget created successfully!"
      expect(page).to have_content "M30 - Summer campaign"
      expect(Budget.last.voting_style).to eq "knapsack"
    end

    scenario "Create budget - Approval voting" do
      visit admin_budgets_path
      click_button "Create new budget"
      click_link "Create multiple headings budget"

      fill_in "Name", with: "M30 - Summer campaign"
      select "Approval", from: "Final voting style"
      click_button "Continue to groups"

      expect(page).to have_content "New participatory budget created successfully!"
      expect(page).to have_content "M30 - Summer campaign"
      expect(Budget.last.voting_style).to eq "approval"
    end

    scenario "Create budget - Approval voting with hide money" do
      visit admin_budgets_path
      click_button "Create new budget"
      click_link "Create multiple headings budget"

      expect(page).to have_select("Final voting style", selected: "Knapsack")
      expect(page).not_to have_selector("#hide_money_checkbox")

      fill_in "Name", with: "Budget hide money"
      select "Approval", from: "Final voting style"
      check "Hide money amount for this budget"
      click_button "Continue to groups"

      expect(page).to have_content "New participatory budget created successfully!"
      expect(page).to have_content "Budget hide money"
      expect(Budget.last.voting_style).to eq "approval"
      expect(Budget.last.hide_money?).to be true
    end

    scenario "Name is mandatory" do
      visit new_admin_budget_path
      click_button "Continue to groups"

      expect(page).not_to have_content "New participatory budget created successfully!"
      expect(page).to have_css(".is-invalid-label", text: "Name")
    end

    scenario "Name should be unique" do
      create(:budget, name: "Existing Name")

      visit new_admin_budget_path
      fill_in "Name", with: "Existing Name"
      click_button "Continue to groups"

      expect(page).not_to have_content "New participatory budget created successfully!"
      expect(page).to have_css(".is-invalid-label", text: "Name")
      expect(page).to have_css("small.form-error", text: "has already been taken")
    end

    scenario "Do not show results and stats settings on new budget" do
      visit new_admin_budget_path

      expect(page).not_to have_content "Show results and stats"
      expect(page).not_to have_field "Show results"
      expect(page).not_to have_field "Show stats"
      expect(page).not_to have_field "Show advanced stats"
    end
  end

  context "Create" do
    scenario "A new budget is always created in draft mode" do
      visit admin_budgets_path
      click_button "Create new budget"
      click_link "Create multiple headings budget"

      fill_in "Name", with: "M30 - Summer campaign"

      click_button "Continue to groups"
      expect(page).to have_content "New participatory budget created successfully!"

      visit admin_budget_path(Budget.last)
      expect(page).to have_content "This participatory budget is in draft mode"
      expect(page).to have_link "Preview budget"
      expect(page).to have_link "Publish budget"
    end

    scenario "Creation of a single-heading budget by steps" do
      visit admin_budgets_path
      click_button "Create new budget"
      click_link "Create single heading budget"

      fill_in "Name", with: "Single heading budget"
      click_button "Continue to groups"

      expect(page).to have_content "New participatory budget created successfully!"
      expect(page).to have_field "Group name", with: "Single heading budget"
      click_button "Continue to headings"

      fill_in "Heading name", with: "Heading name"
      fill_in "Money amount", with: "1000000"
      click_button "Continue to phases"

      expect(page).to have_selector ".budget-phases-table"
      click_link "Finalize"
      expect(page).to have_content "Single heading budget"

      expect(page).to have_selector "h3", count: 1
      within "#group_#{Budget::Group.find_by(name: "Single heading budget").id}" do
        expect(page).to have_selector "h3", text: "Single heading budget"
        within "tbody" do
          expect(page).to have_selector "tr", count: 1
          expect(page).to have_content "Heading name"
        end
      end
    end

    scenario "Creation of a multiple-headings budget by steps" do
      visit admin_budgets_path
      click_button "Create new budget"
      click_link "Create multiple headings budget"

      fill_in "Name", with: "Multiple headings budget"
      click_button "Continue to groups"

      expect(page).to have_content "New participatory budget created successfully!"
      expect(page).to have_content "There are no groups."

      click_button "Add new group"
      fill_in "Group name", with: "All city"
      click_button "Create new group"
      expect(page).to have_content "Group created successfully!"
      within("table") { expect(page).to have_content "All city" }
      expect(page).not_to have_content "There are no groups."

      click_button "Add new group"
      fill_in "Group name", with: "Districts"
      click_button "Create new group"
      expect(page).to have_content "Group created successfully!"
      within("table") { expect(page).to have_content "Districts" }

      click_link "Continue to headings"
      expect(page).to have_select("budget_groups_switcher", selected: "All city")
      expect(page).to have_content "There are no headings."

      click_button "Add new heading"
      fill_in "Heading name", with: "All city"
      fill_in "Money amount", with: "1000000"
      click_button "Create new heading"
      expect(page).to have_content "Heading created successfully!"
      within("table") { expect(page).to have_content "All city" }
      expect(page).not_to have_content "There are no headings."

      select "Districts", from: "budget_groups_switcher"
      expect(page).to have_content "There are no headings."

      click_button "Add new heading"
      fill_in "Heading name", with: "North"
      fill_in "Money amount", with: "500000"
      click_button "Create new heading"
      expect(page).to have_content "Heading created successfully!"
      within("table") { expect(page).to have_content "North" }
      expect(page).not_to have_content "There are no headings."

      click_button "Add new heading"
      fill_in "Heading name", with: "South"
      fill_in "Money amount", with: "500000"
      click_button "Create new heading"
      expect(page).to have_content "Heading created successfully!"
      within("table") { expect(page).to have_content "South" }

      click_link "Continue to phases"
      expect(page).to have_selector ".budget-phases-table"

      phase = Budget.last.phases.first
      within("#budget_phase_#{phase.id}") { click_link "Edit phase" }
      fill_in "Phase's Name", with: "Custom phase name"
      uncheck "Phase enabled"
      click_button "Save changes"

      expect(page).to have_content "Changes saved"

      within "#budget_phase_#{phase.id}" do
        expect(page).to have_content "Custom phase name"
        expect(find("#phase_enabled")).not_to be_checked
      end

      expect(page).to have_field "Name", with: "Multiple headings budget"
      expect(page).to have_selector "h3", count: 2

      within "#group_#{Budget::Group.find_by(name: "All city").id}" do
        expect(page).to have_selector "h3", text: "All city"
        within "tbody" do
          expect(page).to have_selector "tr", count: 1
          expect(page).to have_content "All city"
        end
      end

      within "#group_#{Budget::Group.find_by(name: "Districts").id}" do
        expect(page).to have_selector "h3", text: "Districts"
        within "tbody" do
          expect(page).to have_selector "tr", count: 2
          expect(page).to have_content "North"
          expect(page).to have_content "South"
        end
      end
    end

    scenario "Creation a budget with hide money by steps" do
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
      within("table") { expect(page).to have_content "All city" }
      expect(page).not_to have_content "There are no groups."

      click_link "Continue to headings"
      expect(page).to have_select("budget_groups_switcher", selected: "All city")
      expect(page).to have_content "There are no headings."

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
      visit edit_admin_budget_path(budget)

      within_window(window_opened_by { click_link "Preview budget" }) do
        expect(page).to have_current_path budget_path(budget)
      end
    end

    scenario "Can preview a budget after it is published" do
      visit edit_admin_budget_path(budget)

      accept_confirm { click_link "Publish budget" }

      expect(page).to have_content "Participatory budget published successfully"
      expect(page).not_to have_content "This participatory budget is in draft mode"
      expect(page).not_to have_link "Publish budget"

      within_window(window_opened_by { click_link "Preview budget" }) do
        expect(page).to have_current_path budget_path(budget)
      end
    end
  end

  context "Destroy" do
    let!(:budget) { create(:budget) }
    let(:heading) { create(:budget_heading, budget: budget) }

    scenario "Destroy a budget without investments" do
      visit admin_budgets_path
      click_link "Edit budget"
      accept_confirm { click_link "Delete budget" }

      expect(page).to have_content("Budget deleted successfully")
      expect(page).to have_content("There are no budgets.")
    end

    scenario "Destroy a budget without investments but with administrators and valuators" do
      budget.administrators << Administrator.first
      budget.valuators << create(:valuator)

      visit admin_budgets_path
      click_link "Edit budget"
      click_link "Delete budget"

      page.driver.browser.switch_to.alert do
        expect(page).to have_content "Are you sure? This action will delete the budget '#{budget.name}' "\
                                      "and can't be undone."
      end

      accept_confirm

      expect(page).to have_content "Budget deleted successfully"
      expect(page).to have_content "There are no budgets."
    end

    scenario "Try to destroy a budget with investments" do
      create(:budget_investment, heading: heading)

      visit admin_budgets_path
      click_link "Edit budget"
      accept_confirm { click_link "Delete budget" }

      expect(page).to have_content("You cannot delete a budget that has associated investments")
      expect(page).to have_content("There is 1 budget")
    end

    scenario "Try to destroy a budget with polls" do
      create(:poll, budget: budget)

      visit edit_admin_budget_path(budget)
      click_link "Delete budget"

      expect(page).to have_content("You cannot delete a budget that has an associated poll")
      expect(page).to have_content("There is 1 budget")
    end

    scenario "Allow to delete a budget with administrators or valuators assigned" do
      admin = create(:administrator)
      valuator = create(:valuator)

      budget = create(:budget, administrators: [admin], valuators: [valuator])

      visit admin_budgets_path

      within "#budget_#{budget.id}" do
        click_link "Delete budget"
      end

      accept_confirm

      expect(page).to have_content("Budget deleted successfully")
      expect(page).not_to have_content(budget.name)
    end
  end

  context "Edit" do
    let(:budget) { create(:budget) }

    scenario "Show phases table" do
      travel_to(Date.new(2015, 7, 15)) do
        budget.update!(phase: "selecting")
        budget.phases.valuating.update!(enabled: false)

        visit edit_admin_budget_path(budget)

        expect(page).to have_select "Active phase", selected: "Selecting projects"

        within_table "Phases" do
          within "tr", text: "Information" do
            expect(page).to have_content ["Information", "(Information)"].join("\n")
            expect(page).to have_content "2015-07-15 00:00:00 - 2015-08-14 23:59:59"
            expect(find("#phase_enabled")).to be_checked
            edit_phase_link = edit_admin_budget_budget_phase_path(budget, budget.phases.informing)
            expect(page).to have_link "Edit phase", href: edit_phase_link
          end

          within "tr", text: "Accepting projects" do
            expect(page).to have_content ["Accepting projects", "(Accepting projects)"].join("\n")
            expect(page).to have_content "2015-08-15 00:00:00 - 2015-09-14 23:59:59"
            expect(find("#phase_enabled")).to be_checked
            edit_phase_link = edit_admin_budget_budget_phase_path(budget, budget.phases.accepting)
            expect(page).to have_link "Edit phase", href: edit_phase_link
          end

          within "tr", text: "Reviewing projects" do
            expect(page).to have_content ["Reviewing projects", "(Reviewing projects)"].join("\n")
            expect(page).to have_content "2015-09-15 00:00:00 - 2015-10-14 23:59:59"
            expect(find("#phase_enabled")).to be_checked
            edit_phase_link = edit_admin_budget_budget_phase_path(budget, budget.phases.reviewing)
            expect(page).to have_link "Edit phase", href: edit_phase_link
          end

          within "tr", text: "Selecting projects" do
            expect(page).to have_content ["Selecting projects", "(Selecting projects)"].join("\n")
            expect(page).to have_content "2015-10-15 00:00:00 - 2015-11-14 23:59:59"
            expect(find("#phase_enabled")).to be_checked
            edit_phase_link = edit_admin_budget_budget_phase_path(budget, budget.phases.selecting)
            expect(page).to have_link "Edit phase", href: edit_phase_link
          end

          within "tr", text: "Valuating projects" do
            expect(page).to have_content ["Valuating projects", "(Valuating projects)"].join("\n")
            expect(page).to have_content "2015-11-15 00:00:00 - 2015-12-14 23:59:59"
            expect(find("#phase_enabled")).not_to be_checked
            edit_phase_link = edit_admin_budget_budget_phase_path(budget, budget.phases.valuating)
            expect(page).to have_link "Edit phase", href: edit_phase_link
          end

          within "tr", text: "Publishing projects prices" do
            expect(page).to have_content ["Publishing projects prices", "(Publishing projects prices)"].join("\n")
            expect(page).to have_content "2015-12-15 00:00:00 - 2016-01-14 23:59:59"
            expect(find("#phase_enabled")).to be_checked
            edit_phase_link = edit_admin_budget_budget_phase_path(budget, budget.phases.publishing_prices)
            expect(page).to have_link "Edit phase", href: edit_phase_link
          end

          within "tr", text: "Voting projects" do
            expect(page).to have_content ["Voting projects", "(Voting projects)"].join("\n")
            expect(page).to have_content "2016-01-15 00:00:00 - 2016-02-14 23:59:59"
            expect(find("#phase_enabled")).to be_checked
            edit_phase_link = edit_admin_budget_budget_phase_path(budget, budget.phases.balloting)
            expect(page).to have_link "Edit phase", href: edit_phase_link
          end

          within "tr", text: "Reviewing voting" do
            expect(page).to have_content ["Reviewing voting", "(Reviewing voting)"].join("\n")
            expect(page).to have_content "2016-02-15 00:00:00 - 2016-03-14 23:59:59"
            expect(find("#phase_enabled")).to be_checked
            edit_phase_link = edit_admin_budget_budget_phase_path(budget, budget.phases.reviewing_ballots)
            expect(page).to have_link "Edit phase", href: edit_phase_link
          end

          within "tr", text: "Finished budget" do
            expect(page).to have_content ["Finished budget", "(Finished budget)"].join("\n")
            expect(page).to have_content "2016-03-15 00:00:00 - 2016-04-14 23:59:59"
            expect(find("#phase_enabled")).to be_checked
            edit_phase_link = edit_admin_budget_budget_phase_path(budget, budget.phases.finished)
            expect(page).to have_link "Edit phase", href: edit_phase_link
          end
        end
      end
    end

    scenario "Hide money active" do
      budget_hide_money = create(:budget, :approval, :hide_money)
      group = create(:budget_group, budget: budget_hide_money)
      heading = create(:budget_heading, group: group)
      heading_2 = create(:budget_heading, group: group)

      visit edit_admin_budget_path(budget_hide_money)

      within("#group_#{group.id}") do
        expect(page).to have_content heading.name
        expect(page).to have_content heading_2.name
        expect(page).not_to have_content "Money amount"
      end

      expect(find("#hide_money_checkbox")).to be_checked
      expect(budget_hide_money.voting_style).to eq "approval"
    end

    scenario "Change voting style uncheck hide money" do
      budget_hide_money = create(:budget, :approval, :hide_money)
      hide_money_help_text = "If this option is checked, all fields showing the amount of money "\
                             "will be hidden throughout the process."

      visit edit_admin_budget_path(budget_hide_money)
      expect(find("#hide_money_checkbox")).to be_checked
      expect(page).to have_content hide_money_help_text

      select "Knapsack", from: "Final voting style"
      expect(page).not_to have_selector("#hide_money_checkbox")
      expect(page).not_to have_content hide_money_help_text

      select "Approval", from: "Final voting style"
      expect(find("#hide_money_checkbox")).not_to be_checked
      expect(page).to have_content hide_money_help_text
    end

    scenario "Edit knapsack budget do not show hide money info" do
      budget = create(:budget, :knapsack)
      hide_money_help_text = "If this option is checked, all fields showing the amount of money "\
                             "will be hidden throughout the process."

      visit edit_admin_budget_path(budget)
      expect(page).not_to have_selector("#hide_money_checkbox")
      expect(page).not_to have_content hide_money_help_text

      select "Approval", from: "Final voting style"
      expect(find("#hide_money_checkbox")).not_to be_checked
      expect(page).to have_content hide_money_help_text
    end

    scenario "Edit approval budget show hide money info" do
      budget = create(:budget, :approval)
      hide_money_help_text = "If this option is checked, all fields showing the amount of money "\
                             "will be hidden throughout the process."

      visit edit_admin_budget_path(budget)
      expect(find("#hide_money_checkbox")).not_to be_checked
      expect(page).to have_content hide_money_help_text

      select "Knapsack", from: "Final voting style"
      expect(page).not_to have_selector("#hide_money_checkbox")
      expect(page).not_to have_content hide_money_help_text
    end

    scenario "Show results and stats settings" do
      visit edit_admin_budget_path(budget)

      within_fieldset "Show results and stats" do
        expect(page).to have_field "Show results"
        expect(page).to have_field "Show stats"
        expect(page).to have_field "Show advanced stats"
      end
    end

    scenario "Show groups and headings settings" do
      visit edit_admin_budget_path(budget)

      expect(page).to have_content "GROUPS AND HEADINGS SETTINGS"
      expect(page).to have_link "Add group"
      expect(page).to have_link("Add heading", count: budget.groups.count)

      budget.groups.each do |group|
        expect(page).to have_content group.name
        expect(page).to have_content "Maximum number of headings in which a user can "\
                                     "vote #{group.max_votable_headings}"
        expect(page).to have_link "Edit group #{group.name}"
        expect(page).to have_link "Delete group #{group.name}"

        group.headings.each do |heading|
          expect(page).to have_content heading.name
          expect(page).to have_link "Edit heading #{heading.name}"
          expect(page).to have_link "Delete heading #{heading.name}"
        end
      end
    end

    scenario "Add heading from edit view" do
      visit edit_admin_budget_path(budget)

      budget.groups.each do |group|
        within "#group_#{group.id}" do
          click_link "Add heading"

          fill_in "Heading name", with: "New heading for #{group.name}"
          fill_in "Money amount", with: "1000"
          click_button "Create new heading"
        end

        expect(page).to have_content "New heading for #{group.name}"
        expect(page).to have_content("€1,000", count: budget.groups.count)
      end
    end

    scenario "Remove groups and headings from edit view" do
      visit edit_admin_budget_path(budget)

      budget.groups.each do |group|
        group.headings.each do |heading|
          accept_confirm { click_link "Delete heading #{heading.name}" }
        end

        accept_confirm { click_link "Delete group #{group.name}" }
      end

      expect(budget.groups.count).to eq(0)
      expect(budget.headings.count).to eq(0)
    end

    scenario "Show CTA button in public site if added" do
      visit edit_admin_budget_path(budget)
      expect(page).to have_content("Main call to action (optional)")

      fill_in "Text on the button", with: "Participate now"
      fill_in "The button takes you to (add a link)", with: "https://consulproject.org"
      click_button "Update Budget"

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

    scenario "Phases selector only show enabled phases" do
      budget.phases.each { |phase| phase.update!(enabled: false) }
      budget.phases.accepting.update!(enabled: true)
      budget.phases.balloting.update!(enabled: true)

      visit edit_admin_budget_path(budget)
      expect(page).to have_select("budget_phase", options: ["Accepting projects", "Voting projects"])
    end
  end

  context "Update" do
    scenario "Update budget" do
      budget = create(:budget)
      visit edit_admin_budget_path(budget)

      fill_in "Name", with: "More trees on the streets"
      click_button "Update Budget"

      expect(page).to have_field "Name", with: "More trees on the streets"
      expect(page).to have_current_path admin_budget_path(budget)
    end

    scenario "Select administrators and valuators" do
      admin = Administrator.first
      valuator = create(:valuator)

      budget = create(:budget)

      visit edit_admin_budget_path(budget)

      click_link "Select administrators"
      check admin.name

      click_link "Select valuators"
      check valuator.name

      click_button "Update Budget"

      click_link "1 administrator selected"
      expect(find_field(admin.name)).to be_checked

      click_link "1 valuator selected"
      expect(find_field(valuator.name)).to be_checked
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

      visit edit_admin_budget_path(budget)
      expect(page).not_to have_content "See results"
      click_link "Calculate Winner Investments"
      expect(page).to have_content "Winners being calculated, it may take a minute."
      expect(page).to have_content winner.title
      expect(page).not_to have_content unselected.title
      expect(page).not_to have_content selected.title

      visit edit_admin_budget_path(budget)
      expect(page).to have_content "See results"
    end

    scenario "For a finished Budget" do
      budget = create(:budget, :finished)
      allow_any_instance_of(Budget).to receive(:has_winning_investments?).and_return(true)

      visit edit_admin_budget_path(budget)

      expect(page).to have_content "Calculate Winner Investments"
      expect(page).to have_content "See results"
    end

    scenario "Recalculate for a finished Budget" do
      budget = create(:budget, :finished)
      create(:budget_investment, :winner, budget: budget)

      visit edit_admin_budget_path(budget)

      expect(page).to have_content "Recalculate Winner Investments"
      expect(page).to have_content "See results"
      expect(page).not_to have_content "Calculate Winner Investments"

      visit admin_budget_budget_investments_path(budget)
      click_link "Advanced filters"
      check "Winners"
      click_button "Filter"

      expect(page).to have_content "Recalculate Winner Investments"
      expect(page).not_to have_content "Calculate Winner Investments"
    end
  end
end
