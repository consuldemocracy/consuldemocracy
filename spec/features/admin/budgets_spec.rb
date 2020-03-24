require "rails_helper"

describe "Admin budgets" do
  before do
    admin = create(:administrator)
    login_as(admin.user)
  end

  it_behaves_like "nested imageable",
                  "budget",
                  "new_admin_budget_path",
                  {},
                  "imageable_fill_new_valid_budget",
                  "Continue to groups",
                  "New participatory budget created successfully!"

  context "Feature flag" do
    before do
      Setting["process.budgets"] = nil
    end

    scenario "Disabled with a feature flag" do
      expect { visit admin_budgets_path }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  context "Load" do
    let!(:budget) { create(:budget, slug: "budget_slug") }

    scenario "finds budget by slug" do
      visit admin_budget_path("budget_slug")
    end

    scenario "raises an error if budget slug is not found" do
      expect do
        visit admin_budget_path("wrong_budget")
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "raises an error if budget id is not found" do
      expect do
        visit admin_budget_path(0)
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end

  context "Index" do
    scenario "Displaying no open budgets text" do
      visit admin_budgets_path

      expect(page).to have_content("There are no budgets.")
    end

    scenario "Displaying budgets" do
      budget = create(:budget)
      visit admin_budgets_path

      expect(page).to have_content(budget.name)
      expect(page).to have_content(translated_phase_name(phase_kind: budget.phase))
    end

    scenario "Displaying budget information" do
      budget_single = create(:budget, :accepting)
      budget_multiple = create(:budget, :balloting)

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
        expect(page).to have_content("#{budget_single.phases.first.starts_at.to_date} 00:00 - "\
                                     "#{budget_single.phases.last.ends_at.to_date - 1} 23:59")
      end

      within "#budget_#{budget_multiple.id}" do
        expect(page).to have_content(budget_multiple.name)
        expect(page).to have_content("Voting projects")
        expect(page).to have_content("Multiple headings")
        expect(page).to have_content("(7/9)")
        expect(page).to have_content("9 months")
        expect(page).to have_content("#{budget_multiple.phases.first.starts_at.to_date} 00:00 - "\
                                     "#{budget_multiple.phases.last.ends_at.to_date - 1} 23:59")
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
      drafting_budget  = create(:budget, :drafting)
      accepting_budget = create(:budget, :accepting)
      selecting_budget = create(:budget, :selecting)
      balloting_budget = create(:budget, :balloting)
      finished_budget  = create(:budget, :finished)

      visit admin_budgets_path
      expect(page).to have_content(drafting_budget.name)
      expect(page).to have_content(accepting_budget.name)
      expect(page).to have_content(selecting_budget.name)
      expect(page).to have_content(balloting_budget.name)
      expect(page).to have_content(finished_budget.name)

      within "#budget_#{finished_budget.id}" do
        expect(page).to have_content("Completed")
      end

      click_link "Finished"
      expect(page).not_to have_content(drafting_budget.name)
      expect(page).not_to have_content(accepting_budget.name)
      expect(page).not_to have_content(selecting_budget.name)
      expect(page).not_to have_content(balloting_budget.name)
      expect(page).to have_content(finished_budget.name)

      click_link "Open"
      expect(page).to have_content(drafting_budget.name)
      expect(page).to have_content(accepting_budget.name)
      expect(page).to have_content(selecting_budget.name)
      expect(page).to have_content(balloting_budget.name)
      expect(page).not_to have_content(finished_budget.name)
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

  context "New" do
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

      expect(page).not_to have_content "Results and statistics settings"
      expect(page).not_to have_content "Show results"
      expect(page).not_to have_content "Show stats"
      expect(page).not_to have_content "Show advanced stats"
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

      expect(page).to have_selector "#budget-phases-table"
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

    scenario "Creation of a multiple-headings budget by steps", :js do
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
      expect(page).to have_selector "#budget-phases-table"

      phase = Budget.last.phases.first
      within("#budget_phase_#{phase.id}") { click_link "Edit content" }
      fill_in "Phase's Name", with: "Custom phase name"
      uncheck "Phase enabled"
      click_button "Save changes"

      expect(page).to have_content "Changes saved"
      within "#budget_phase_#{phase.id}" do
        expect(page).to have_content "Custom phase name"
        expect(find("#phase_enabled")).not_to be_checked
      end

      click_link "Finalize"
      expect(page).to have_content "Multiple headings budget"

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
  end

  context "Publish" do
    let(:budget) { create(:budget, :drafting) }

    scenario "Can preview budget before and after it is published" do
      visit admin_budget_path(budget)

      click_link "Preview budget"

      expect(page).to have_current_path budget_path(budget)

      visit admin_budget_path(budget)
      budget.update!(published: true)

      expect(page).to have_link "Preview budget"
      click_link "Preview budget"

      expect(page).to have_current_path budget_path(budget)
    end

    scenario "Publishing a budget" do
      visit admin_budget_path(budget)

      click_link "Publish budget"

      expect(page).to have_content "Participaroty budget published successfully"
      expect(page).to have_link "Preview budget"
      expect(page).not_to have_content "This participatory budget is in draft mode"
      expect(page).not_to have_link "Publish budget"
    end
  end

  context "Destroy" do
    let!(:budget) { create(:budget) }
    let(:heading) { create(:budget_heading, budget: budget) }

    scenario "Destroy a budget without investments" do
      visit admin_budgets_path
      click_link "Edit budget"
      click_link "Delete budget"

      expect(page).to have_content("Budget deleted successfully")
      expect(page).to have_content("There are no budgets.")
    end

    scenario "Try to destroy a budget with investments" do
      create(:budget_investment, heading: heading)

      visit admin_budgets_path
      click_link "Edit budget"
      click_link "Delete budget"

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
  end

  context "Edit" do
    let!(:budget) { create(:budget) }

    scenario "Show phases table" do
      budget.update!(phase: "selecting")

      visit admin_budgets_path
      click_link "Edit budget"

      expect(page).to have_select("budget_phase", selected: "Selecting projects")

      within "#budget-phases-table" do
        Budget::Phase::PHASE_KINDS.each do |phase_kind|
          break if phase_kind == Budget::Phase::PHASE_KINDS.last

          phase_index = Budget::Phase::PHASE_KINDS.index(phase_kind)
          next_phase_kind = Budget::Phase::PHASE_KINDS[phase_index + 1]
          next_phase_name = translated_phase_name(phase_kind: next_phase_kind)
          expect(translated_phase_name(phase_kind: phase_kind)).to appear_before(next_phase_name)
        end

        budget.phases.each do |phase|
          edit_phase_link = edit_admin_budget_budget_phase_path(budget, phase)

          within "#budget_phase_#{phase.id}" do
            expect(page).to have_content(translated_phase_name(phase_kind: phase.kind))
            expect(page).to have_content("#{phase.starts_at.to_date} 00:00 - "\
                                         "#{phase.ends_at.to_date - 1} 23:59")
            expect(page).to have_link("Edit content", href: edit_phase_link)
            expect(page).to have_content("Active") if budget.current_phase == phase
          end
        end
      end
    end

    scenario "Show results and stats settings" do
      visit edit_admin_budget_path(budget)

      expect(page).to have_content "Results and statistics settings"
      expect(page).to have_content "Show results"
      expect(page).to have_content "Show stats"
      expect(page).to have_content "Show advanced stats"
    end

    scenario "Show groups and headings settings" do
      visit edit_admin_budget_path(budget)

      expect(page).to have_content "Groups and headings settings"
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

    scenario "Show CTA button in public site if added" do
      visit edit_admin_budget_path(budget)
      expect(page).to have_content("Main call to action (optional)")

      fill_in "Text on the button", with: "Participate now"
      fill_in "The button takes you to (add a link)", with: "https://consulproject.org"
      click_button "Update Budget"

      visit budgets_path
      expect(page).to have_link("Participate now", href: "https://consulproject.org")
    end

    scenario "Changing name for current locale will update the slug if budget is in draft phase", :js do
      budget.update!(published: false)
      old_slug = budget.slug

      visit edit_admin_budget_path(budget)

      select "Español", from: :add_language
      fill_in "Name", with: "Spanish name"
      click_button "Update Budget"

      expect(page).to have_content "Participatory budget updated successfully"
      expect(budget.reload.slug).to eq old_slug

      visit edit_admin_budget_path(budget)

      select "English", from: :select_language
      fill_in "Name", with: "New English Name"
      click_button "Update Budget"

      expect(page).to have_content "Participatory budget updated successfully"
      expect(budget.reload.slug).not_to eq old_slug
      expect(budget.slug).to eq "new-english-name"
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

    scenario "Deselect all selected staff", :js do
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
    scenario "For a Budget in reviewing balloting", :js do
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

def translated_phase_name(phase_kind: kind)
  I18n.t("budgets.phase.#{phase_kind}")
end
