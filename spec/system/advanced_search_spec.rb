require "rails_helper"

describe "Advanced search" do
  let(:budget)  { create(:budget, name: "Big Budget") }
  let(:heading) { create(:budget_heading, budget: budget, name: "More hospitals") }

  scenario "Search debates" do
    debate1 = create(:debate, title: "Get Schwifty")
    debate2 = create(:debate, title: "Schwifty Hello")
    debate3 = create(:debate, title: "Do not show me")

    visit debates_path

    click_button "Advanced search"
    fill_in "With the text", with: "Schwifty"
    click_button "Filter"

    expect(page).to have_content("There are 2 debates")

    within("#debates") do
      expect(page).to have_content(debate1.title)
      expect(page).to have_content(debate2.title)
      expect(page).not_to have_content(debate3.title)
    end
  end

  scenario "Search proposals" do
    proposal1 = create(:proposal, title: "Get Schwifty")
    proposal2 = create(:proposal, title: "Schwifty Hello")
    proposal3 = create(:proposal, title: "Do not show me")

    visit proposals_path

    click_button "Advanced search"
    fill_in "With the text", with: "Schwifty"
    click_button "Filter"

    expect(page).to have_content("There are 2 citizen proposals")

    within("#proposals") do
      expect(page).to have_content(proposal1.title)
      expect(page).to have_content(proposal2.title)
      expect(page).not_to have_content(proposal3.title)
    end
  end

  scenario "Search investments" do
    bdgt_invest1 = create(:budget_investment, heading: heading, title: "Get Schwifty")
    bdgt_invest2 = create(:budget_investment, heading: heading, title: "Schwifty Hello")
    bdgt_invest3 = create(:budget_investment, heading: heading, title: "Do not show me")

    visit budget_investments_path(budget)

    click_button "Advanced search"
    fill_in "With the text", with: "Schwifty"
    click_button "Filter"

    expect(page).to have_content("There are 2 investments")

    within("#budget-investments") do
      expect(page).to have_content(bdgt_invest1.title)
      expect(page).to have_content(bdgt_invest2.title)
      expect(page).not_to have_content(bdgt_invest3.title)
    end
  end

  context "Search by date" do
    context "Predefined date ranges" do
      scenario "Last day" do
        bdgt_invest1 = create(:budget_investment, heading: heading, created_at: 1.minute.ago)
        bdgt_invest2 = create(:budget_investment, heading: heading, created_at: 1.hour.ago)
        bdgt_invest3 = create(:budget_investment, heading: heading, created_at: 2.days.ago)

        visit budget_investments_path(budget)

        click_button "Advanced search"
        select "Last 24 hours", from: "js-advanced-search-date-min"
        click_button "Filter"

        expect(page).to have_content("There are 2 investments")

        within("#budget-investments") do
          expect(page).to have_content(bdgt_invest1.title)
          expect(page).to have_content(bdgt_invest2.title)
          expect(page).not_to have_content(bdgt_invest3.title)
        end
      end

      scenario "Last week" do
        debate1 = create(:debate, created_at: 1.day.ago)
        debate2 = create(:debate, created_at: 5.days.ago)
        debate3 = create(:debate, created_at: 8.days.ago)

        visit debates_path

        click_button "Advanced search"
        select "Last week", from: "js-advanced-search-date-min"
        click_button "Filter"

        within("#debates") do
          expect(page).to have_css(".debate", count: 2)

          expect(page).to have_content(debate1.title)
          expect(page).to have_content(debate2.title)
          expect(page).not_to have_content(debate3.title)
        end
      end

      scenario "Last month" do
        proposal1 = create(:proposal, created_at: 10.days.ago)
        proposal2 = create(:proposal, created_at: 20.days.ago)
        proposal3 = create(:proposal, created_at: 33.days.ago)

        visit proposals_path

        click_button "Advanced search"
        select "Last month", from: "js-advanced-search-date-min"
        click_button "Filter"

        expect(page).to have_content("There are 2 citizen proposals")

        within("#proposals") do
          expect(page).to have_content(proposal1.title)
          expect(page).to have_content(proposal2.title)
          expect(page).not_to have_content(proposal3.title)
        end
      end

      scenario "Last year" do
        bdgt_invest1 = create(:budget_investment, heading: heading, created_at: 300.days.ago)
        bdgt_invest2 = create(:budget_investment, heading: heading, created_at: 350.days.ago)
        bdgt_invest3 = create(:budget_investment, heading: heading, created_at: 370.days.ago)

        visit budget_investments_path(budget)

        click_button "Advanced search"
        select "Last year", from: "js-advanced-search-date-min"
        click_button "Filter"

        expect(page).to have_content("There are 2 investments")

        within("#budget-investments") do
          expect(page).to have_content(bdgt_invest1.title)
          expect(page).to have_content(bdgt_invest2.title)
          expect(page).not_to have_content(bdgt_invest3.title)
        end
      end
    end

    scenario "Search by custom date range" do
      debate1 = create(:debate, created_at: 2.days.ago)
      debate2 = create(:debate, created_at: 3.days.ago)
      debate3 = create(:debate, created_at: 9.days.ago)

      visit debates_path

      click_button "Advanced search"
      select "Customized", from: "js-advanced-search-date-min"
      fill_in "advanced_search_date_min", with: 7.days.ago.strftime("%d/%m/%Y")
      fill_in "advanced_search_date_max", with: 1.day.ago.strftime("%d/%m/%Y")
      find_field("With the text").click
      click_button "Filter"

      within("#debates") do
        expect(page).to have_css(".debate", count: 2)

        expect(page).to have_content(debate1.title)
        expect(page).to have_content(debate2.title)
        expect(page).not_to have_content(debate3.title)
      end
    end

    scenario "Search by custom invalid date range" do
      proposal1 = create(:proposal, created_at: 2.days.ago)
      proposal2 = create(:proposal, created_at: 3.days.ago)
      proposal3 = create(:proposal, created_at: 9.days.ago)

      visit proposals_path

      click_button "Advanced search"
      select "Customized", from: "js-advanced-search-date-min"
      fill_in "advanced_search_date_min", with: 4000.years.ago.strftime("%d/%m/%Y")
      fill_in "advanced_search_date_max", with: "13/13/2199"
      find_field("With the text").click
      click_button "Filter"

      expect(page).to have_content("There are 3 citizen proposals")

      within("#proposals") do
        expect(page).to have_content(proposal1.title)
        expect(page).to have_content(proposal2.title)
        expect(page).to have_content(proposal3.title)
      end
    end

    scenario "Search by multiple filters" do
      Setting["feature.sdg"] = true
      Setting["sdg.process.budgets"] = true

      create(:budget_investment, heading: heading, title: "Get Schwifty", sdg_goals: [SDG::Goal[7]], created_at: 1.minute.ago)
      create(:budget_investment, heading: heading, title: "Hello Schwifty", sdg_goals: [SDG::Goal[7]], created_at: 2.days.ago)
      create(:budget_investment, heading: heading, title: "Save the forest")

      visit budget_investments_path(budget)

      click_button "Advanced search"
      fill_in "With the text", with: "Schwifty"
      select "7. Affordable and Clean Energy", from: "By SDG"
      select "Last 24 hours", from: "js-advanced-search-date-min"

      click_button "Filter"

      expect(page).to have_content("There is 1 investment")

      within("#budget-investments") do
        expect(page).to have_content "Get Schwifty"
      end
    end

    scenario "Maintain advanced search criteria" do
      Setting["feature.sdg"] = true
      Setting["sdg.process.debates"] = true

      visit debates_path
      click_button "Advanced search"

      fill_in "With the text", with: "Schwifty"
      select "7. Affordable and Clean Energy", from: "By SDG"
      select "Last 24 hours", from: "js-advanced-search-date-min"

      click_button "Filter"

      within ".advanced-search-form" do
        expect(page).to have_selector("input[name='search'][value='Schwifty']")
        expect(page).to have_select("By SDG", selected: "7. Affordable and Clean Energy")
        expect(page).to have_select("advanced_search[date_min]", selected: "Last 24 hours")
      end
    end

    scenario "Maintain custom date search criteria" do
      visit proposals_path
      click_button "Advanced search"

      select "Customized", from: "js-advanced-search-date-min"
      fill_in "advanced_search_date_min", with: 7.days.ago.strftime("%d/%m/%Y")
      fill_in "advanced_search_date_max", with: 1.day.ago.strftime("%d/%m/%Y")
      find_field("With the text").click
      click_button "Filter"

      expect(page).to have_content("citizen proposals cannot be found")

      within ".advanced-search-form" do
        expect(page).to have_select("advanced_search[date_min]", selected: "Customized")
        expect(page).to have_selector("input[name='advanced_search[date_min]'][value*='#{7.days.ago.strftime("%d/%m/%Y")}']")
        expect(page).to have_selector("input[name='advanced_search[date_max]'][value*='#{1.day.ago.strftime("%d/%m/%Y")}']")
      end
    end
  end

  describe "SDG" do
    before do
      Setting["feature.sdg"] = true
      Setting["sdg.process.debates"] = true
      Setting["sdg.process.proposals"] = true
      Setting["sdg.process.budgets"] = true
    end

    scenario "Search by goal" do
      create(:budget_investment, title: "Purifier", heading: heading, sdg_goals: [SDG::Goal[6]])
      create(:budget_investment, title: "Hospital", heading: heading, sdg_goals: [SDG::Goal[3]])

      goal_6_targets = [
        "6.1. Safe and Affordable Drinking Water",
        "6.2. End Open Defecation and Provide Access to Sanitation and Hygiene",
        "6.3. Improve Water Quality, Wastewater Treatment and Safe Reuse",
        "6.4. Increase Water-Use Efficiency and Ensure Freshwater Supplies",
        "6.5. Implement Integrated Water Resources Management",
        "6.6. Protect and Restore Water-Related Ecosystems",
        "6.A. Expand Water and Sanitation Support to Developing Countries",
        "6.B. Support Local Engagement in Water and Sanitation Management"
      ]

      visit budget_investments_path(budget)
      click_button "Advanced search"
      select "6. Clean Water and Sanitation", from: "By SDG"
      click_button "Filter"

      expect(page).to have_content("There is 1 investment")

      within("#budget-investments") do
        expect(page).to have_content "Purifier"
        expect(page).not_to have_content "Hospital"
      end

      expect(page).to have_select "By target",
                                  selected: "Select a target",
                                  enabled_options: ["Select a target"] + goal_6_targets
    end

    scenario "Search by target" do
      create(:debate, title: "Unrelated")
      create(:debate, title: "High school", sdg_targets: [SDG::Target["4.1"]])
      create(:debate, title: "Preschool", sdg_targets: [SDG::Target["4.2"]])

      visit debates_path
      click_button "Advanced search"
      select "4.2. Equal Access to Quality Pre-Primary Education", from: "By target"
      click_button "Filter"

      expect(page).to have_content("There is 1 debate")

      within("#debates") do
        expect(page).to have_content("Preschool")
        expect(page).not_to have_content("High school")
        expect(page).not_to have_content("Unrelated")
      end
    end

    scenario "Dynamic target options depending on the selected goal" do
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

      visit proposals_path

      click_button "Advanced search"
      select "1. No Poverty", from: "By SDG"

      expect(page).to have_select "By target",
                                  selected: "Select a target",
                                  enabled_options: ["Select a target"] + goal_1_targets

      select "1.1. Eradicate Extreme Poverty", from: "By target"
      select "13. Climate Action", from: "By SDG"

      expect(page).to have_select "By target",
                                  selected: "Select a target",
                                  enabled_options: ["Select a target"] + goal_13_targets

      select "13.3. Build Knowledge and Capacity to Meet Climate Change", from: "By target"
      select "Select a goal", from: "By SDG"

      expect(page).to have_select "By target",
                                  selected: "13.3. Build Knowledge and Capacity to Meet Climate Change",
                                  disabled_options: []
    end
  end
end
