require "rails_helper"

describe "Budgets" do
  let(:budget)             { create(:budget) }
  let(:level_two_user)     { create(:user, :level_two) }
  let(:allowed_phase_list) { ["balloting", "reviewing_ballots", "finished"] }

  context "Load" do
    before { budget.update(slug: "budget_slug") }

    scenario "finds budget by slug" do
      visit budget_path("budget_slug")

      expect(page).to have_content budget.name
    end
  end

  describe "Index" do
    describe "Normal index" do
      let!(:group1)   { create(:budget_group, budget: budget) }
      let!(:group2)   { create(:budget_group, budget: budget) }
      let!(:heading1) { create(:budget_heading, group: group1) }
      let!(:heading2) { create(:budget_heading, group: group2) }

      scenario "Show normal index with links publishing prices" do
        budget.update!(phase: "publishing_prices")

        visit budgets_path

        within(".budget-subheader") do
          expect(page).to have_content("Publishing projects prices")
        end

        within("#budget_info") do
          expect(page).to have_content(group1.name)
          expect(page).to have_content(group2.name)
          expect(page).to have_content(heading1.name)
          expect(page).to have_content(budget.formatted_heading_price(heading1))
          expect(page).to have_content(heading2.name)
          expect(page).to have_content(budget.formatted_heading_price(heading2))
        end

        expect(page).not_to have_content("#finished_budgets")
      end
    end

    scenario "Show finished budgets list" do
      finished_budget_1 = create(:budget, :finished)
      finished_budget_2 = create(:budget, :finished)
      drafting_budget = create(:budget, :drafting)
      visit budgets_path

      within("#finished_budgets") do
        expect(page).to     have_content(finished_budget_1.name)
        expect(page).to     have_content(finished_budget_2.name)
        expect(page).not_to have_content(budget.name)
        expect(page).not_to have_content(drafting_budget.name)
      end
    end

    scenario "Show headings ordered by name" do
      group = create(:budget_group, budget: budget)
      last_heading = create(:budget_heading, group: group, name: "BBB")
      first_heading = create(:budget_heading, group: group, name: "AAA")

      visit budgets_path

      expect(first_heading.name).to appear_before(last_heading.name)
    end

    scenario "Show groups and headings for missing translations" do
      group1 = create(:budget_group, budget: budget)
      group2 = create(:budget_group, budget: budget)

      heading1 = create(:budget_heading, group: group1, price: 1_000_000)
      heading2 = create(:budget_heading, group: group2, price: 2_000_000)

      visit budgets_path locale: :es

      within("#budget_info") do
        expect(page).to have_content group1.name
        expect(page).to have_content group2.name
        expect(page).to have_content heading1.name
        expect(page).to have_content "1.000.000 €"
        expect(page).to have_content heading2.name
        expect(page).to have_content "2.000.000 €"
      end
    end

    scenario "Show informing index without links" do
      budget.update!(phase: "informing")
      heading = create(:budget_heading, budget: budget)

      visit budgets_path

      within("#budget_info") do
        expect(page).not_to have_link heading.name
        expect(page).to have_content "#{heading.name}\n€1,000,000"
      end
    end

    scenario "Show finished index without heading links" do
      budget.update!(phase: "finished")
      heading = create(:budget_heading, budget: budget)

      visit budgets_path

      within("#budget_info") do
        expect(page).not_to have_link heading.name
        expect(page).to have_content "#{heading.name}\n€1,000,000"
      end
    end

    scenario "Hide money on single heading budget" do
      budget = create(:budget, :finished, :hide_money)
      heading = create(:budget_heading, budget: budget)

      visit budgets_path

      within("#budget_info") do
        expect(page).to have_content heading.name
        expect(page).not_to have_content "€"
      end
    end

    scenario "Hide money on multiple headings budget" do
      budget = create(:budget, :finished, :hide_money)
      heading1 = create(:budget_heading, budget: budget)
      heading2 = create(:budget_heading, budget: budget)
      heading3 = create(:budget_heading, budget: budget)

      visit budgets_path

      within("#budget_info") do
        expect(page).to have_content heading1.name
        expect(page).to have_content heading2.name
        expect(page).to have_content heading3.name
        expect(page).not_to have_content "€"
      end
    end

    scenario "No budgets" do
      Budget.destroy_all

      visit budgets_path

      expect(page).to have_content "There are no budgets"
    end

    scenario "Show heading for budget with single heading" do
      group = create(:budget_group, budget: budget, name: "Single group")
      create(:budget_heading, group: group, name: "New heading", price: 10_000)

      visit budgets_path

      expect(page).not_to have_content "Single group"

      within ".single-heading" do
        expect(page).to have_content "New heading"
        expect(page).to have_content "€10,000"
      end
    end

    scenario "Show group and headings for budget with multiple headings" do
      group = create(:budget_group, budget: budget, name: "New group")
      create(:budget_heading, group: group, name: "New heading", price: 10_000)
      create(:budget_heading, group: group, name: "Other new heading", price: 30_000)

      visit budgets_path

      within("#groups_and_headings") do
        expect(page).to have_content "New group"
        expect(page).to have_content "New heading"
        expect(page).to have_content "€10,000"
        expect(page).to have_content "Other new heading"
        expect(page).to have_content "€30,000"
      end
    end
  end

  scenario "Index shows only published phases" do
    budget.update!(phase: :finished)
    phases = budget.phases

    phases.informing.update!(starts_at: "30-12-2017", ends_at: "31-12-2017", enabled: true,
                             description: "Description of informing phase",
                             name: "Custom name for informing phase")

    phases.accepting.update!(starts_at: "01-01-2018", ends_at: "10-01-2018", enabled: true,
                            description: "Description of accepting phase",
                            name: "Custom name for accepting phase")

    phases.reviewing.update!(starts_at: "11-01-2018", ends_at: "20-01-2018", enabled: false,
                            description: "Description of reviewing phase")

    phases.selecting.update!(starts_at: "21-01-2018", ends_at: "01-02-2018", enabled: true,
                            description: "Description of selecting phase",
                            name: "Custom name for selecting phase")

    phases.valuating.update!(starts_at: "10-02-2018", ends_at: "20-02-2018", enabled: false,
                            description: "Description of valuating phase")

    phases.publishing_prices.update!(starts_at: "21-02-2018", ends_at: "01-03-2018", enabled: false,
                                    description: "Description of publishing prices phase")

    phases.balloting.update!(starts_at: "02-03-2018", ends_at: "10-03-2018", enabled: true,
                            description: "Description of balloting phase")

    phases.reviewing_ballots.update!(starts_at: "11-03-2018", ends_at: "20-03-2018", enabled: false,
                                    description: "Description of reviewing ballots phase")

    phases.finished.update!(starts_at: "21-03-2018", ends_at: "30-03-2018", enabled: true,
                           description: "Description of finished phase")

    visit budgets_path

    expect(page).not_to have_link "Reviewing projects"
    expect(page).not_to have_link "Valuating projects"
    expect(page).not_to have_link "Publishing projects prices"
    expect(page).not_to have_link "Reviewing voting"

    click_link "Custom name for informing phase"

    expect(page).to have_content "Description of informing phase"
    expect(page).to have_content "December 30, 2017 - December 31, 2017"

    click_link "Custom name for accepting phase"

    within("#phase-2-custom-name-for-accepting-phase") do
      expect(page).to have_link "Previous phase", href: "#phase-1-custom-name-for-informing-phase"
      expect(page).to have_link "Next phase", href: "#phase-3-custom-name-for-selecting-phase"
    end

    expect(page).to have_content "Description of accepting phase"
    expect(page).to have_content "January 01, 2018 - January 20, 2018"

    click_link "Custom name for selecting phase"

    expect(page).to have_content "Description of selecting phase"
    expect(page).to have_content "January 21, 2018 - March 01, 2018"

    click_link "Voting projects"

    expect(page).to have_content "Description of balloting phase"
    expect(page).to have_content "March 02, 2018 - March 20, 2018"

    click_link "Current phase Finished budget"

    expect(page).to have_content "Description of finished phase"
    expect(page).to have_content "March 21, 2018 - March 29, 2018"

    expect(page).to have_css(".tabs-panel.is-active", count: 1)
  end

  context "Index map" do
    let(:heading) { create(:budget_heading, budget: budget) }

    before do
      Setting["feature.map"] = true
    end

    scenario "Display investment's map location markers" do
      investment1 = create(:budget_investment, heading: heading)
      investment2 = create(:budget_investment, heading: heading)
      investment3 = create(:budget_investment, heading: heading)

      create(:map_location, longitude: 40.1234, latitude: -3.634, investment: investment1)
      create(:map_location, longitude: 40.1235, latitude: -3.635, investment: investment2)
      create(:map_location, longitude: 40.1236, latitude: -3.636, investment: investment3)

      visit budgets_path

      within ".map_location" do
        expect(page).to have_css(".map-icon", count: 3, visible: :all)
      end
    end

    scenario "Display all investment's map location if there are no selected" do
      budget.update!(phase: :publishing_prices)

      investment1 = create(:budget_investment, heading: heading)
      investment2 = create(:budget_investment, heading: heading)
      investment3 = create(:budget_investment, heading: heading)
      investment4 = create(:budget_investment, heading: heading)

      investment1.create_map_location(longitude: 40.1234, latitude: 3.1234, zoom: 10)
      investment2.create_map_location(longitude: 40.1235, latitude: 3.1235, zoom: 10)
      investment3.create_map_location(longitude: 40.1236, latitude: 3.1236, zoom: 10)
      investment4.create_map_location(longitude: 40.1240, latitude: 3.1240, zoom: 10)

      visit budgets_path

      within ".map_location" do
        expect(page).to have_css(".map-icon", count: 4, visible: :all)
      end
    end

    scenario "Display only selected investment's map location from publishing prices phase" do
      budget.update!(phase: :publishing_prices)

      investment1 = create(:budget_investment, :selected, heading: heading)
      investment2 = create(:budget_investment, :selected, heading: heading)
      investment3 = create(:budget_investment, heading: heading)
      investment4 = create(:budget_investment, heading: heading)

      investment1.create_map_location(longitude: 40.1234, latitude: 3.1234, zoom: 10)
      investment2.create_map_location(longitude: 40.1235, latitude: 3.1235, zoom: 10)
      investment3.create_map_location(longitude: 40.1236, latitude: 3.1236, zoom: 10)
      investment4.create_map_location(longitude: 40.1240, latitude: 3.1240, zoom: 10)

      visit budgets_path

      within ".map_location" do
        expect(page).to have_css(".map-icon", count: 2, visible: :all)
      end
    end

    scenario "Skip invalid map markers" do
      map_locations = []

      investment = create(:budget_investment, heading: heading)

      map_locations << { longitude: 40.123456789, latitude: 3.12345678 }
      map_locations << { longitude: 40.123456789, latitude: "********" }
      map_locations << { longitude: "**********", latitude: 3.12345678 }

      coordinates = map_locations.map do |map_location|
        {
          lat: map_location[:latitude],
          long: map_location[:longitude],
          investment_title: investment.title,
          investment_id: investment.id,
          budget_id: budget.id
        }
      end

      allow_any_instance_of(Budgets::MapComponent).to receive(:coordinates).and_return(coordinates)

      visit budgets_path

      within ".map_location" do
        expect(page).to have_css(".map-icon", count: 1, visible: :all)
      end
    end
  end

  context "Show" do
    let!(:budget) { create(:budget, :selecting) }

    scenario "Take into account headings with the same name from a different budget" do
      group1 = create(:budget_group, budget: budget, name: "New York")
      heading1 = create(:budget_heading, group: group1, name: "Brooklyn")
      heading2 = create(:budget_heading, group: group1, name: "Queens")

      budget2 = create(:budget)
      group2 = create(:budget_group, budget: budget2, name: "New York")
      heading3 = create(:budget_heading, group: group2, name: "Brooklyn")
      heading4 = create(:budget_heading, group: group2, name: "Queens")

      visit budget_group_path(budget, group1)

      expect(page).to have_css("#budget_heading_#{heading1.id}")
      expect(page).to have_css("#budget_heading_#{heading2.id}")

      expect(page).not_to have_css("#budget_heading_#{heading3.id}")
      expect(page).not_to have_css("#budget_heading_#{heading4.id}")
    end

    scenario "See results button is showed if the budget has finished" do
      user = create(:user)
      budget = create(:budget, :finished)

      login_as(user)
      visit budget_path(budget)

      expect(page).to have_link "See results"
    end

    scenario "Show investments list" do
      budget = create(:budget, phase: "balloting")
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)

      create_list(:budget_investment, 3, :selected, heading: heading, price: 999)

      visit budget_path(budget)

      within(".investments-list") do
        expect(page).to have_content "List of investments"
        expect(page).to have_content "PRICE", count: 3
      end

      expect(page).to have_link "See all investments",
                                href: budget_investments_path(budget)
    end

    scenario "Show investments list when budget has multiple headings" do
      budget = create(:budget, phase: "accepting")
      group = create(:budget_group, budget: budget)
      heading_1 = create(:budget_heading, group: group)
      create(:budget_heading, group: group)

      create_list(:budget_investment, 3, :selected, heading: heading_1, price: 999)

      visit budget_path(budget)

      expect(page).to have_css ".investments-list"
    end

    scenario "Show supports info on selecting phase" do
      budget = create(:budget, :selecting)
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)
      voter = create(:user, :level_two)

      create_list(:budget_investment, 3, :selected, heading: heading, voters: [voter])

      login_as(voter)
      visit budget_path(budget)

      expect(page).to have_content "It's time to support projects!"
      expect(page).to have_content "So far you've supported 3 projects."
    end

    scenario "Show supports only if the support has not been removed" do
      Setting["feature.remove_investments_supports"] = true
      voter = create(:user, :level_two)
      budget = create(:budget, phase: "selecting")
      investment = create(:budget_investment, :selected, budget: budget)

      login_as(voter)

      visit budget_path(budget)

      expect(page).to have_content "So far you've supported 0 projects."

      visit budget_investment_path(budget, investment)

      within("#budget_investment_#{investment.id}_votes") do
        click_button "Support"

        expect(page).to have_content "You have already supported this investment project."
      end

      visit budget_path(budget)

      expect(page).to have_content "So far you've supported 1 project."

      visit budget_investment_path(budget, investment)

      within("#budget_investment_#{investment.id}_votes") do
        click_button "Remove your support"

        expect(page).to have_content "No supports"
      end

      visit budget_path(budget)

      expect(page).to have_content "So far you've supported 0 projects."
    end

    scenario "Main link takes you to the defined URL" do
      budget.update!(main_link_text: "See other budgets!", main_link_url: budgets_path)

      visit budget_path(budget)
      click_link "See other budgets!"

      expect(page).to have_current_path budgets_path
    end
  end

  context "In Drafting phase" do
    before do
      budget.update!(published: false)
      create(:budget)
    end

    context "Listed" do
      scenario "Not listed at public budgets list" do
        visit budgets_path

        expect(page).not_to have_content(budget.name)
      end
    end
  end
end
