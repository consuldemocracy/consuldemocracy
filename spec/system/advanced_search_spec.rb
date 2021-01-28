require "rails_helper"

describe "Advanced search", :js do
  let(:budget)  { create(:budget, name: "Big Budget") }
  let(:heading) { create(:budget_heading, budget: budget, name: "More hospitals") }

  scenario "Search debates" do
    debate1 = create(:debate, title: "Get Schwifty")
    debate2 = create(:debate, title: "Schwifty Hello")
    debate3 = create(:debate, title: "Do not show me")

    visit debates_path

    click_link "Advanced search"
    fill_in "Write the text", with: "Schwifty"
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

    click_link "Advanced search"
    fill_in "Write the text", with: "Schwifty"
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

    click_link "Advanced search"
    fill_in "Write the text", with: "Schwifty"
    click_button "Filter"

    expect(page).to have_content("There are 2 investments")

    within("#budget-investments") do
      expect(page).to have_content(bdgt_invest1.title)
      expect(page).to have_content(bdgt_invest2.title)
      expect(page).not_to have_content(bdgt_invest3.title)
    end
  end

  context "Search by author type" do
    scenario "Public employee" do
      ana = create :user, official_level: 1
      john = create :user, official_level: 2

      debate1 = create(:debate, author: ana)
      debate2 = create(:debate, author: ana)
      debate3 = create(:debate, author: john)

      visit debates_path

      click_link "Advanced search"
      select Setting["official_level_1_name"], from: "advanced_search_official_level"
      click_button "Filter"

      expect(page).to have_content("There are 2 debates")

      within("#debates") do
        expect(page).to have_content(debate1.title)
        expect(page).to have_content(debate2.title)
        expect(page).not_to have_content(debate3.title)
      end
    end

    scenario "Municipal Organization" do
      ana = create :user, official_level: 2
      john = create :user, official_level: 3

      proposal1 = create(:proposal, author: ana)
      proposal2 = create(:proposal, author: ana)
      proposal3 = create(:proposal, author: john)

      visit proposals_path

      click_link "Advanced search"
      select Setting["official_level_2_name"], from: "advanced_search_official_level"
      click_button "Filter"

      expect(page).to have_content("There are 2 citizen proposals")

      within("#proposals") do
        expect(page).to have_content(proposal1.title)
        expect(page).to have_content(proposal2.title)
        expect(page).not_to have_content(proposal3.title)
      end
    end

    scenario "General director" do
      ana = create :user, official_level: 3
      john = create :user, official_level: 4

      bdgt_invest1 = create(:budget_investment, heading: heading, author: ana)
      bdgt_invest2 = create(:budget_investment, heading: heading, author: ana)
      bdgt_invest3 = create(:budget_investment, heading: heading, author: john)

      visit budget_investments_path(budget)

      click_link "Advanced search"
      select Setting["official_level_3_name"], from: "advanced_search_official_level"
      click_button "Filter"

      expect(page).to have_content("There are 2 investments")

      within("#budget-investments") do
        expect(page).to have_content(bdgt_invest1.title)
        expect(page).to have_content(bdgt_invest2.title)
        expect(page).not_to have_content(bdgt_invest3.title)
      end
    end

    scenario "City councillor" do
      ana = create :user, official_level: 4
      john = create :user, official_level: 5

      debate1 = create(:debate, author: ana)
      debate2 = create(:debate, author: ana)
      debate3 = create(:debate, author: john)

      visit debates_path

      click_link "Advanced search"
      select Setting["official_level_4_name"], from: "advanced_search_official_level"
      click_button "Filter"

      expect(page).to have_content("There are 2 debates")

      within("#debates") do
        expect(page).to have_content(debate1.title)
        expect(page).to have_content(debate2.title)
        expect(page).not_to have_content(debate3.title)
      end
    end

    scenario "Mayoress" do
      ana = create :user, official_level: 5
      john = create :user, official_level: 4

      proposal1 = create(:proposal, author: ana)
      proposal2 = create(:proposal, author: ana)
      proposal3 = create(:proposal, author: john)

      visit proposals_path

      click_link "Advanced search"
      select Setting["official_level_5_name"], from: "advanced_search_official_level"
      click_button "Filter"

      expect(page).to have_content("There are 2 citizen proposals")

      within("#proposals") do
        expect(page).to have_content(proposal1.title)
        expect(page).to have_content(proposal2.title)
        expect(page).not_to have_content(proposal3.title)
      end
    end

    context "Search by date" do
      context "Predefined date ranges" do
        scenario "Last day" do
          bdgt_invest1 = create(:budget_investment, heading: heading, created_at: 1.minute.ago)
          bdgt_invest2 = create(:budget_investment, heading: heading, created_at: 1.hour.ago)
          bdgt_invest3 = create(:budget_investment, heading: heading, created_at: 2.days.ago)

          visit budget_investments_path(budget)

          click_link "Advanced search"
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

          click_link "Advanced search"
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

          click_link "Advanced search"
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

          click_link "Advanced search"
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

        click_link "Advanced search"
        select "Customized", from: "js-advanced-search-date-min"
        fill_in "advanced_search_date_min", with: 7.days.ago
        fill_in "advanced_search_date_max", with: 1.day.ago
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

        click_link "Advanced search"
        select "Customized", from: "js-advanced-search-date-min"
        fill_in "advanced_search_date_min", with: 4000.years.ago
        fill_in "advanced_search_date_max", with: "wrong date"
        click_button "Filter"

        expect(page).to have_content("There are 3 citizen proposals")

        within("#proposals") do
          expect(page).to have_content(proposal1.title)
          expect(page).to have_content(proposal2.title)
          expect(page).to have_content(proposal3.title)
        end
      end

      scenario "Search by multiple filters" do
        ana  = create :user, official_level: 1
        john = create :user, official_level: 1

        create(:budget_investment, heading: heading, title: "Get Schwifty",   author: ana,  created_at: 1.minute.ago)
        create(:budget_investment, heading: heading, title: "Hello Schwifty", author: john, created_at: 2.days.ago)
        create(:budget_investment, heading: heading, title: "Save the forest")

        visit budget_investments_path(budget)

        click_link "Advanced search"
        fill_in "Write the text", with: "Schwifty"
        select Setting["official_level_1_name"], from: "advanced_search_official_level"
        select "Last 24 hours", from: "js-advanced-search-date-min"

        click_button "Filter"

        expect(page).to have_content("There is 1 investment")

        within("#budget-investments") do
          expect(page).to have_content "Get Schwifty"
        end
      end

      scenario "Maintain advanced search criteria" do
        visit debates_path
        click_link "Advanced search"

        fill_in "Write the text", with: "Schwifty"
        select Setting["official_level_1_name"], from: "advanced_search_official_level"
        select "Last 24 hours", from: "js-advanced-search-date-min"

        click_button "Filter"

        within "#js-advanced-search" do
          expect(page).to have_selector("input[name='search'][value='Schwifty']")
          expect(page).to have_select("advanced_search[official_level]", selected: Setting["official_level_1_name"])
          expect(page).to have_select("advanced_search[date_min]", selected: "Last 24 hours")
        end
      end

      scenario "Maintain custom date search criteria" do
        visit proposals_path
        click_link "Advanced search"

        select "Customized", from: "js-advanced-search-date-min"
        fill_in "advanced_search_date_min", with: 7.days.ago.strftime("%d/%m/%Y")
        fill_in "advanced_search_date_max", with: 1.day.ago.strftime("%d/%m/%Y")
        click_button "Filter"

        expect(page).to have_content("citizen proposals cannot be found")

        within "#js-advanced-search" do
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

        visit budget_investments_path(budget)
        click_link "Advanced search"
        select "6. Clean Water and Sanitation", from: "By SDG"
        click_button "Filter"

        expect(page).to have_content("There is 1 investment")

        within("#budget-investments") do
          expect(page).to have_content "Purifier"
          expect(page).not_to have_content "Hospital"
        end

        expect(page).to have_select "By target",
                                    selected: "Select a target",
                                    enabled_options: ["Select a target"] + %w[6.1 6.2 6.3 6.4 6.5 6.6 6.A 6.B]
      end

      scenario "Search by target" do
        create(:debate, title: "Unrelated")
        create(:debate, title: "High school", sdg_targets: [SDG::Target["4.1"]])
        create(:debate, title: "Preschool", sdg_targets: [SDG::Target["4.2"]])

        visit debates_path
        click_link "Advanced search"
        select "4.2", from: "By target"
        click_button "Filter"

        expect(page).to have_content("There is 1 debate")

        within("#debates") do
          expect(page).to have_content("Preschool")
          expect(page).not_to have_content("High school")
          expect(page).not_to have_content("Unrelated")
        end
      end

      scenario "Dynamic target options depending on the selected goal" do
        visit proposals_path

        click_link "Advanced search"
        select "1. No Poverty", from: "By SDG"

        expect(page).to have_select "By target",
                                    selected: "Select a target",
                                    enabled_options: ["Select a target"] + %w[1.1 1.2 1.3 1.4 1.5 1.A 1.B]

        select "1.1", from: "By target"
        select "13. Climate Action", from: "By SDG"

        expect(page).to have_select "By target",
                                    selected: "Select a target",
                                    enabled_options: ["Select a target"] + %w[13.1 13.2 13.3 13.A 13.B]

        select "13.1", from: "By target"
        select "Select a goal", from: "By SDG"

        expect(page).to have_select "By target", selected: "13.1", disabled_options: []
      end
    end
  end
end
