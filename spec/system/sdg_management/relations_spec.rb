require "rails_helper"

describe "SDG Relations" do
  before do
    login_as(create(:administrator).user)
    Setting["feature.sdg"] = true
    Setting["sdg.process.budgets"] = true
    Setting["sdg.process.debates"] = true
    Setting["sdg.process.legislation"] = true
    Setting["sdg.process.polls"] = true
    Setting["sdg.process.proposals"] = true
  end

  scenario "navigation" do
    visit sdg_management_root_path

    within("#side_menu") { click_link "Participatory budgets" }

    expect(page).to have_current_path "/sdg_management/budget/investments"
    expect(page).to have_css "h2", exact_text: "Participatory budgets"
    expect(page).to have_css "li.is-active h2", exact_text: "Pending"

    within("#side_menu") { click_link "Debates" }

    expect(page).to have_current_path "/sdg_management/debates"
    expect(page).to have_css "h2", exact_text: "Debates"
    expect(page).to have_css "li.is-active h2", exact_text: "Pending"

    within("#side_menu") { click_link "Legislation processes" }

    expect(page).to have_current_path "/sdg_management/legislation/processes"
    expect(page).to have_css "h2", exact_text: "Legislation processes"
    expect(page).to have_css "li.is-active h2", exact_text: "Pending"

    within("#side_menu") { click_link "Legislation proposals" }

    expect(page).to have_current_path "/sdg_management/legislation/proposals"
    expect(page).to have_css "h2", exact_text: "Legislation proposals"
    expect(page).to have_css "li.is-active h2", exact_text: "Pending"

    within("#side_menu") { click_link "Polls" }

    expect(page).to have_current_path "/sdg_management/polls"
    expect(page).to have_css "h2", exact_text: "Polls"
    expect(page).to have_css "li.is-active h2", exact_text: "Pending"

    within("#side_menu") { click_link "Proposals" }

    expect(page).to have_current_path "/sdg_management/proposals"
    expect(page).to have_css "h2", exact_text: "Proposals"
    expect(page).to have_css "li.is-active h2", exact_text: "Pending"
  end

  describe "Index" do
    scenario "list records for the current model" do
      create(:debate, title: "I'm a debate")
      create(:proposal, title: "And I'm a proposal")

      visit sdg_management_debates_path

      expect(page).to have_text "I'm a debate"
      expect(page).not_to have_text "I'm a proposal"

      visit sdg_management_proposals_path

      expect(page).to have_text "I'm a proposal"
      expect(page).not_to have_text "I'm a debate"
    end

    scenario "list goals and target for all records" do
      redistribute = create(:proposal, title: "Resources distribution")
      redistribute.sdg_goals = [SDG::Goal[1]]
      redistribute.sdg_targets = [SDG::Target["1.1"]]

      treatment = create(:proposal, title: "Treatment system")
      treatment.sdg_goals = [SDG::Goal[6]]
      treatment.sdg_targets = [SDG::Target["6.1"], SDG::Target["6.2"]]

      visit sdg_management_proposals_path

      within("tr", text: "Resources distribution") do
        expect(page).to have_content "1.1"
      end

      within("tr", text: "Treatment system") do
        expect(page).to have_content "6.1, 6.2"
      end
    end

    scenario "shows link to edit a record" do
      create(:budget_investment, title: "Build a hospital")

      visit sdg_management_budget_investments_path

      within("tr", text: "Build a hospital") do
        click_link "Manage goals and targets"
      end

      expect(page).to have_css "h2", exact_text: "Build a hospital"
    end

    scenario "list records pending to review for the current model by default" do
      create(:debate, title: "I'm a debate")
      create(:sdg_review, relatable: create(:debate, title: "I'm a reviewed debate"))

      visit sdg_management_debates_path

      expect(page).to have_css "li.is-active h2", exact_text: "Pending"
      expect(page).to have_text "I'm a debate"
      expect(page).not_to have_text "I'm a reviewed debate"
    end

    scenario "list all records for the current model when user clicks on 'all' tab" do
      create(:debate, title: "I'm a debate")
      create(:sdg_review, relatable: create(:debate, title: "I'm a reviewed debate"))

      visit sdg_management_debates_path
      click_link "All"

      expect(page).to have_text "I'm a debate"
      expect(page).to have_text "I'm a reviewed debate"
    end

    scenario "list reviewed records for the current model when user clicks on 'reviewed' tab" do
      create(:debate, title: "I'm a debate")
      create(:sdg_review, relatable: create(:debate, title: "I'm a reviewed debate"))

      visit sdg_management_debates_path
      click_link "Marked as reviewed"

      expect(page).not_to have_text "I'm a debate"
      expect(page).to have_text "I'm a reviewed debate"
    end

    describe "search" do
      scenario "search by terms" do
        create(:poll, name: "Internet speech freedom")
        create(:poll, name: "SDG interest")

        visit sdg_management_polls_path

        fill_in "search", with: "speech"
        click_button "Search"

        expect(page).to have_content "Internet speech freedom"
        expect(page).not_to have_content "SDG interest"
        expect(page).to have_css "li.is-active h2", exact_text: "Pending"
      end

      scenario "goal filter" do
        create(:budget_investment, title: "School", sdg_goals: [SDG::Goal[4]])
        create(:budget_investment, title: "Hospital", sdg_goals: [SDG::Goal[3]])

        goal_4_targets = [
          "4.1. Free Primary and Secondary Education",
          "4.2. Equal Access to Quality Pre-Primary Education",
          "4.3. Equal Access to Affordable Technical, Vocational and Higher Education",
          "4.4. Increase the Number of People with Relevant Skills for Financial Success",
          "4.5. Eliminate All Discrimination in Education",
          "4.6. Universal Literacy and Numeracy",
          "4.7. Education for Sustainable Development and Global Citizenship",
          "4.A. Build and Upgrade Inclusive and Safe Schools",
          "4.B. Expand Higher Education Scholarships for Developing Countries",
          "4.C. Increase the supply of qualified teachers In Developing Countries"
        ]

        visit sdg_management_budget_investments_path
        select "4. Quality Education", from: "goal_code"
        click_button "Search"

        expect(page).to have_content "School"
        expect(page).not_to have_content "Hospital"
        expect(page).to have_css "li.is-active h2", exact_text: "Pending"

        expect(page).to have_select "By target",
                                    selected: "All targets",
                                    enabled_options: ["All targets"] + goal_4_targets
      end

      scenario "target filter" do
        create(:budget_investment, title: "School", sdg_targets: [SDG::Target[4.1]])
        create(:budget_investment, title: "Preschool", sdg_targets: [SDG::Target[4.2]])

        visit sdg_management_budget_investments_path
        select "4.1. Free Primary and Secondary Education", from: "target_code"
        click_button "Search"

        expect(page).to have_content "School"
        expect(page).not_to have_content "Preschool"
        expect(page).to have_css "li.is-active h2", exact_text: "Pending"
      end

      scenario "local target filter" do
        create(:sdg_local_target, code: "4.1.1", title: "Improve local schools")
        create(:sdg_local_target, code: "4.1.2", title: "Increase the teacher per student rate")
        create(:debate, title: "Rebuild local schools", sdg_local_targets: [SDG::LocalTarget["4.1.1"]])
        create(:debate, title: "Hire teachers", sdg_local_targets: [SDG::LocalTarget["4.1.2"]])

        visit sdg_management_debates_path
        select "4.1.1. Improve local schools", from: "target_code"
        click_button "Search"

        expect(page).to have_content "Rebuild local schools"
        expect(page).not_to have_content "Hire teachers"
      end

      scenario "search within current tab" do
        create(:proposal, title: "Proposal pending review")
        create(:sdg_review, relatable: create(:proposal, title: "Proposal already reviewed"))

        visit sdg_management_proposals_path(filter: "pending_sdg_review")

        expect(page).to have_content "Proposal pending review"
        expect(page).not_to have_content "Proposal already reviewed"

        fill_in "search", with: "non existent"
        click_button "Search"

        expect(page).not_to have_content "Proposal pending review"
        expect(page).to have_css "li.is-active h2", exact_text: "Pending"

        visit sdg_management_proposals_path(filter: "sdg_reviewed")

        expect(page).not_to have_content "Proposal pending review"
        expect(page).to have_content "Proposal already reviewed"

        fill_in "search", with: "non existent"
        click_button "Search"

        expect(page).not_to have_content "Proposal already reviewed"
        expect(page).to have_css "li.is-active h2", exact_text: "Marked as reviewed"

        visit sdg_management_proposals_path(filter: "all")

        expect(page).to have_content "Proposal pending review"
        expect(page).to have_content "Proposal already reviewed"

        fill_in "search", with: "non existent"
        click_button "Search"

        expect(page).not_to have_content "Proposal pending review"
        expect(page).not_to have_content "Proposal already reviewed"
        expect(page).to have_css "li.is-active h2", exact_text: "All"
      end

      scenario "dynamic target options depending on the selected goal" do
        goal_1_targets = [
          "1.1. Eradicate Extreme Poverty",
          "1.2. Reduce Poverty by at Least 50%",
          "1.3. Implement Social Protection Systems",
          "1.4. Equal Rights to Ownership, Basic Services, Technology and Economic Resources",
          "1.5. Build Resilience to Environmental, Economic and Social Disasters",
          "1.A. Mobilize Resources to Implement Policies to End Poverty",
          "1.B. Create pro-poor and gender-sensitive policy frameworks"
        ]

        goal_13_targets = [
          "13.1. Strengthen resilience and Adaptive Capacity to Climate Related Disasters",
          "13.2. Integrate Climate Change Measures into Policies and Planning",
          "13.3. Build Knowledge and Capacity to Meet Climate Change",
          "13.A. Implement the UN Framework Convention on Climate Change",
          "13.B. Promote Mechanisms to Raise Capacity for Planning and Management"
        ]

        visit sdg_management_polls_path

        select "1. No Poverty", from: "By goal"

        expect(page).to have_select "By target",
                                    selected: "All targets",
                                    enabled_options: ["All targets"] + goal_1_targets

        select "1.1. Eradicate Extreme Poverty", from: "By target"
        select "13. Climate Action", from: "By goal"

        expect(page).to have_select "By target",
                                    selected: "All targets",
                                    enabled_options: ["All targets"] + goal_13_targets

        select "13.3. Build Knowledge and Capacity to Meet Climate Change", from: "By target"
        select "All goals", from: "By goal"

        expect(page).to have_select "By target",
                                    selected: "13.3. Build Knowledge and Capacity to Meet Climate Change",
                                    disabled_options: []
      end
    end
  end

  describe "Edit" do
    scenario "allows adding the goals, global targets and local targets and marks the resource as reviewed" do
      process = create(:legislation_process, title: "SDG process")
      create(:sdg_local_target, code: "1.1.1")
      create(:sdg_local_target, code: "3.3.3")
      process.sdg_goals = [SDG::Goal[3], SDG::Goal[4]]
      process.sdg_targets = [SDG::Target[3.3], SDG::LocalTarget["3.3.3"]]

      visit sdg_management_edit_legislation_process_path(process)

      find(:css, ".sdg-related-list-selector-input").set("1.2, 2, 1.1.1, ")

      click_button "Update Process"

      expect(page).to have_content "Process updated successfully and marked as reviewed"

      click_link "Marked as reviewed"

      within("tr", text: "SDG process") do
        expect(page).to have_css "td", exact_text: "1.1.1, 1.2, 3.3, 3.3.3"
        expect(page).to have_css "td", exact_text: "1, 2, 3, 4"
      end
    end

    scenario "allows removing the goals, global target and local_targets" do
      process = create(:legislation_process, title: "SDG process")
      create(:sdg_local_target, code: "1.1.1")
      process.sdg_goals = [SDG::Goal[1], SDG::Goal[2], SDG::Goal[3]]
      process.sdg_targets = [SDG::Target[2.1], SDG::Target[3.3], SDG::LocalTarget["1.1.1"]]

      visit sdg_management_edit_legislation_process_path(process)

      remove_sdg_goal_or_target_tag(2)
      remove_sdg_goal_or_target_tag(3.3)
      remove_sdg_goal_or_target_tag("1.1.1")

      click_button "Update Process"

      expect(page).to have_content "Process updated successfully and marked as reviewed"

      click_link "Marked as reviewed"

      within("tr", text: "SDG process") do
        expect(page).to have_css "td", exact_text: "1, 2, 3"
        expect(page).to have_css "td", exact_text: "2.1"
      end
    end

    scenario "does not show the review notice when resource was already reviewed" do
      debate = create(:sdg_review, relatable: create(:debate, title: "SDG debate")).relatable

      visit sdg_management_edit_debate_path(debate, filter: "sdg_reviewed")
      find(:css, ".sdg-related-list-selector-input").set("1.2, 2.1,")
      click_button "Update Debate"

      expect(page).not_to have_content "Debate updated successfully and marked as reviewed"
      expect(page).to have_content "Debate updated successfully"

      click_link "Marked as reviewed"

      within("tr", text: "SDG debate") do
        expect(page).to have_css "td", exact_text: "1.2, 2.1"
      end
    end

    scenario "allows adding the goals, global targets and local targets with autocomplete" do
      process = create(:legislation_process, title: "SDG process")
      create(:sdg_local_target, code: "1.1.1")
      visit sdg_management_edit_legislation_process_path(process)

      fill_in "Goals and Targets", with: "3"
      within(".amsify-list") { find(:css, "[data-val='3']").click }

      within(".amsify-suggestags-input-area") { expect(page).to have_content "SDG3" }

      fill_in "Goals and Targets", with: "1.1"
      within(".amsify-list") { find(:css, "[data-val='1.1']").click }

      within(".amsify-suggestags-input-area") { expect(page).to have_content "1.1" }

      fill_in "Goals and Targets", with: "1.1.1"
      within(".amsify-list") { find(:css, "[data-val='1.1.1']").click }

      within(".amsify-suggestags-input-area") { expect(page).to have_content "1.1.1" }

      click_button "Update Process"

      expect(page).to have_content "Process updated successfully and marked as reviewed"

      click_link "Marked as reviewed"

      within("tr", text: "SDG process") do
        expect(page).to have_css "td", exact_text: "1, 3"
        expect(page).to have_css "td", exact_text: "1.1, 1.1.1"
      end
    end

    scenario "allows adding only white list suggestions" do
      process = create(:legislation_process, title: "SDG process")

      visit sdg_management_edit_legislation_process_path(process)
      fill_in "Goals and Targets", with: "tag nonexistent,"

      within(".amsify-suggestags-input-area") { expect(page).not_to have_content "tag nonexistent" }
    end

    describe "by clicking on a Goal icon" do
      scenario "allows adding a Goal" do
        process = create(:legislation_process, title: "SDG process")

        visit sdg_management_edit_legislation_process_path(process)
        click_sdg_goal(1)
        click_button "Update Process"

        expect(page).to have_content "Process updated successfully and marked as reviewed"

        click_link "Marked as reviewed"

        within("tr", text: "SDG process") do
          expect(page).to have_css "td", exact_text: "1"
        end
      end

      scenario "allows remove a Goal" do
        process = create(:legislation_process, title: "SDG process")
        process.sdg_goals = [SDG::Goal[1], SDG::Goal[2]]

        visit sdg_management_edit_legislation_process_path(process)
        click_sdg_goal(1)
        click_button "Update Process"

        expect(page).to have_content "Process updated successfully and marked as reviewed"

        click_link "Marked as reviewed"

        within("tr", text: "SDG process") do
          expect(page).to have_css "td", exact_text: "2"
        end
      end
    end

    describe "manage goals icon status" do
      scenario "when add a tag related to Goal, the icon will be checked" do
        process = create(:legislation_process, title: "SDG process")

        visit sdg_management_edit_legislation_process_path(process)
        click_sdg_goal(1)

        expect(find("input[data-code='1']")).to be_checked
      end

      scenario "when remove a last tag related to a Goal, the icon will not be checked" do
        process = create(:legislation_process, title: "SDG process")
        create(:sdg_local_target, code: "1.1.1")
        process.sdg_goals = [SDG::Goal[1]]
        process.sdg_targets = [SDG::Target[1.1], SDG::LocalTarget["1.1.1"]]

        visit sdg_management_edit_legislation_process_path(process)
        remove_sdg_goal_or_target_tag(1)

        expect(find("input[data-code='1']")).to be_checked

        remove_sdg_goal_or_target_tag(1.1)

        expect(find("input[data-code='1']")).to be_checked

        remove_sdg_goal_or_target_tag("1.1.1")

        expect(find("input[data-code='1']")).not_to be_checked
      end

      context "when we have a Goal and a related Target selected" do
        scenario "we can remove and add same Goal always keeping the icon as checked" do
          process = create(:legislation_process, title: "SDG process")
          process.sdg_goals = [SDG::Goal[1]]
          process.sdg_targets = [SDG::Target[1.1]]

          visit sdg_management_edit_legislation_process_path(process)
          click_sdg_goal(1)

          expect(find("input[data-code='1']")).to be_checked

          click_sdg_goal(1)

          expect(find("input[data-code='1']")).to be_checked
        end
      end

      scenario "Help page link opens in new window" do
        process = create(:legislation_process, title: "SDG process")

        visit sdg_management_edit_legislation_process_path(process)

        within_window(window_opened_by { click_link "SDG help page" }) do
          expect(page).to have_content "Sustainable Development Goals help"
        end
      end
    end

    describe "help section" do
      scenario "when add new tag render title in help section" do
        process = create(:legislation_process, title: "SDG process")

        visit sdg_management_edit_legislation_process_path(process)
        click_sdg_goal(1)

        within(".help-section") { expect(page).to have_content "No Poverty" }
      end

      scenario "when remove a tag remove his title in help section" do
        process = create(:legislation_process, title: "SDG process")
        process.sdg_goals = [SDG::Goal[1]]

        visit sdg_management_edit_legislation_process_path(process)

        within(".help-section") { expect(page).to have_content "No Poverty" }

        remove_sdg_goal_or_target_tag(1)

        expect(page).not_to have_content "No Poverty"
      end
    end
  end
end
