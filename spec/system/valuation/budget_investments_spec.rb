require "rails_helper"

describe "Valuation budget investments" do
  let(:budget) { create(:budget, :valuating) }
  let(:valuator) do
    create(:valuator, user: create(:user, username: "Rachel", email: "rachel@valuators.org"))
  end

  before do
    login_as(valuator.user)
  end

  context "Load" do
    before { budget.update(slug: "budget_slug") }

    scenario "finds investment using budget slug" do
      visit valuation_budget_budget_investments_path("budget_slug")

      expect(page).to have_content budget.name
    end
  end

  scenario "Display link to valuation section" do
    visit root_path
    click_link "Menu"

    expect(page).to have_link "Valuation", href: valuation_root_path
  end

  describe "Index" do
    scenario "Index shows budget investments assigned to current valuator" do
      investment1 = create(:budget_investment, :visible_to_valuators, budget: budget, valuators: [valuator])
      investment2 = create(:budget_investment, :visible_to_valuators, budget: budget)

      visit valuation_budget_budget_investments_path(budget)

      expect(page).to have_content(investment1.title)
      expect(page).not_to have_content(investment2.title)
    end

    scenario "Index shows no budget investment to admins no valuators" do
      investment1 = create(:budget_investment, :visible_to_valuators, budget: budget, valuators: [valuator])
      investment2 = create(:budget_investment, :visible_to_valuators, budget: budget)

      logout
      login_as create(:administrator).user
      visit valuation_budget_budget_investments_path(budget)

      expect(page).not_to have_content(investment1.title)
      expect(page).not_to have_content(investment2.title)
    end

    scenario "Index orders budget investments by votes" do
      investment10  = create(:budget_investment, :visible_to_valuators, budget: budget,
                                                                        valuators: [valuator],
                                                                        cached_votes_up: 10)
      investment100 = create(:budget_investment, :visible_to_valuators, budget: budget,
                                                                        valuators: [valuator],
                                                                        cached_votes_up: 100)
      investment1   = create(:budget_investment, :visible_to_valuators, budget: budget,
                                                                        valuators: [valuator],
                                                                        cached_votes_up: 1)

      visit valuation_budget_budget_investments_path(budget)

      expect(investment100.title).to appear_before(investment10.title)
      expect(investment10.title).to appear_before(investment1.title)
    end

    scenario "Index displays investments paginated" do
      per_page = 3
      allow(Budget::Investment).to receive(:default_per_page).and_return(per_page)
      (per_page + 2).times do
        create(:budget_investment, :visible_to_valuators, budget: budget, valuators: [valuator])
      end

      visit valuation_budget_budget_investments_path(budget)

      expect(page).to have_css(".budget_investment", count: per_page)
      within("ul.pagination") do
        expect(page).to have_content("1")
        expect(page).to have_content("2")
        expect(page).not_to have_content("3")
        click_link "Next", exact: false
      end

      expect(page).to have_css(".budget_investment", count: 2)
    end

    scenario "Index filtering by heading" do
      group = create(:budget_group, budget: budget)
      valuating_heading = create(:budget_heading, name: "Only Valuating", group: group)
      valuating_finished_heading = create(:budget_heading, name: "Valuating&Finished", group: group)
      finished_heading = create(:budget_heading, name: "Only Finished", group: group)
      create(:budget_investment, :visible_to_valuators, title: "Valuating Investment ONE",
                                                        heading: valuating_heading,
                                                        budget: budget,
                                                        valuators: [valuator])
      create(:budget_investment, :visible_to_valuators, title: "Valuating Investment TWO",
                                                        heading: valuating_finished_heading,
                                                        budget: budget,
                                                        valuators: [valuator])
      create(:budget_investment, :visible_to_valuators, :finished, title: "Finished ONE",
                                                                   heading: valuating_finished_heading,
                                                                   budget: budget,
                                                                   valuators: [valuator])
      create(:budget_investment, :visible_to_valuators, :finished, title: "Finished TWO",
                                                                   heading: finished_heading,
                                                                   budget: budget,
                                                                   valuators: [valuator])

      visit valuation_budget_budget_investments_path(budget)

      expect(page).to have_link("Valuating Investment ONE")
      expect(page).to have_link("Valuating Investment TWO")
      expect(page).not_to have_link("Finished ONE")
      expect(page).not_to have_link("Finished TWO")

      expect(page).to have_link("All headings (4)")
      expect(page).to have_link("Only Valuating (1)")
      expect(page).to have_link("Valuating&Finished (2)")
      expect(page).to have_link("Only Finished (1)")

      click_link "Only Valuating (1)", exact: false
      expect(page).to have_link("Valuating Investment ONE")
      expect(page).not_to have_link("Valuating Investment TWO")
      expect(page).not_to have_link("Finished ONE")
      expect(page).not_to have_link("Finished TWO")

      click_link "Valuation finished"
      expect(page).not_to have_link("Valuating Investment ONE")
      expect(page).not_to have_link("Valuating Investment TWO")
      expect(page).not_to have_link("Finished ONE")
      expect(page).not_to have_link("Finished TWO")

      click_link "Valuating&Finished (2)", exact: false
      expect(page).not_to have_link("Valuating Investment ONE")
      expect(page).to have_link("Valuating Investment TWO")
      expect(page).not_to have_link("Finished ONE")
      expect(page).not_to have_link("Finished TWO")

      click_link "Valuation finished"
      expect(page).not_to have_link("Valuating Investment ONE")
      expect(page).not_to have_link("Valuating Investment TWO")
      expect(page).to have_link("Finished ONE")
      expect(page).not_to have_link("Finished TWO")

      click_link "Only Finished (1)", exact: false
      expect(page).not_to have_link("Valuating Investment ONE")
      expect(page).not_to have_link("Valuating Investment TWO")
      expect(page).not_to have_link("Finished ONE")
      expect(page).not_to have_link("Finished TWO")

      click_link "Valuation finished"
      expect(page).not_to have_link("Valuating Investment ONE")
      expect(page).not_to have_link("Valuating Investment TWO")
      expect(page).not_to have_link("Finished ONE")
      expect(page).to have_link("Finished TWO")
    end

    scenario "Current filter is properly highlighted" do
      filters_links = { "valuating" => "Under valuation",
                        "valuation_finished" => "Valuation finished" }

      visit valuation_budget_budget_investments_path(budget)

      expect(page).not_to have_link(filters_links.values.first)
      filters_links.keys.drop(1).each { |filter| expect(page).to have_link(filters_links[filter]) }

      filters_links.each_pair do |current_filter, link|
        visit valuation_budget_budget_investments_path(budget, filter: current_filter)

        expect(page).not_to have_link(link)

        (filters_links.keys - [current_filter]).each do |filter|
          expect(page).to have_link(filters_links[filter])
        end
      end
    end

    scenario "Index filtering by valuation status" do
      create(:budget_investment, :visible_to_valuators,
             budget: budget, valuators: [valuator], title: "Ongoing valuation")
      create(:budget_investment, :visible_to_valuators, :finished,
             budget: budget, valuators: [valuator], title: "Old idea")

      visit valuation_budget_budget_investments_path(budget)

      expect(page).to have_content("Ongoing valuation")
      expect(page).not_to have_content("Old idea")

      visit valuation_budget_budget_investments_path(budget, filter: "valuating")

      expect(page).to have_content("Ongoing valuation")
      expect(page).not_to have_content("Old idea")

      visit valuation_budget_budget_investments_path(budget, filter: "valuation_finished")

      expect(page).not_to have_content("Ongoing valuation")
      expect(page).to have_content("Old idea")
    end
  end

  describe "Show" do
    let(:administrator) do
      create(:administrator, user: create(:user, username: "Ana", email: "ana@admins.org"))
    end
    let(:second_valuator) do
      create(:valuator, user: create(:user, username: "Rick", email: "rick@valuators.org"))
    end
    let(:investment) do
      create(:budget_investment, :unfeasible, budget: budget, price: 1234,
                                 unfeasibility_explanation: "It is impossible",
                                 administrator: administrator,
                                 valuators: [valuator, second_valuator])
    end

    scenario "visible for assigned valuators" do
      investment.update!(visible_to_valuators: true)
      visit valuation_budget_budget_investments_path(budget)

      click_link investment.title

      expect(page).to have_content("Investment preview")
      expect(page).to have_content(investment.title)
      expect(page).to have_content(investment.description)
      expect(page).to have_content(investment.author.name)
      expect(page).to have_content(investment.heading.name)
      expect(page).to have_content("1234")
      expect(page).to have_content("Unfeasible")
      expect(page).to have_content("It is impossible")
      expect(page).to have_content("Ana (ana@admins.org)")

      within("#assigned_valuators") do
        expect(page).to have_content("Rachel (rachel@valuators.org)")
        expect(page).to have_content("Rick (rick@valuators.org)")
      end
    end

    scenario "visible for admins" do
      logout
      login_as create(:administrator).user

      visit valuation_budget_budget_investment_path(budget, investment)

      expect(page).to have_content("Investment preview")
      expect(page).to have_content(investment.title)
      expect(page).to have_content(investment.description)
      expect(page).to have_content(investment.author.name)
      expect(page).to have_content(investment.heading.name)
      expect(page).to have_content("1234")
      expect(page).to have_content("Unfeasible")
      expect(page).to have_content("It is impossible")
      expect(page).to have_content("Ana (ana@admins.org)")

      within("#assigned_valuators") do
        expect(page).to have_content("Rachel (rachel@valuators.org)")
        expect(page).to have_content("Rick (rick@valuators.org)")
      end
    end
  end

  describe "Valuate" do
    let(:admin) { create(:administrator) }
    let(:investment) do
      create(:budget_investment, budget: budget, price: nil, administrator: admin, valuators: [valuator])
    end

    scenario "Dossier empty by default" do
      investment.update!(visible_to_valuators: true)

      visit valuation_budget_budget_investments_path(budget)
      click_link investment.title

      within("#price") { expect(page).to have_content("Undefined") }
      within("#price_first_year") { expect(page).to have_content("Undefined") }
      within("#duration") { expect(page).to have_content("Undefined") }
      within("#feasibility") { expect(page).to have_content("Undecided") }
      expect(page).not_to have_content("Valuation finished")
    end

    scenario "Edit dossier" do
      investment.update!(visible_to_valuators: true)
      visit valuation_budget_budget_investments_path(budget)
      within("#budget_investment_#{investment.id}") do
        click_link "Edit dossier"
      end

      fill_in "budget_investment_price", with: "12345"
      fill_in "budget_investment_price_first_year", with: "9876"
      fill_in "budget_investment_price_explanation", with: "Very cheap idea"
      choose  "budget_investment_feasibility_feasible"
      fill_in "budget_investment_duration", with: "19 months"
      click_button "Save changes"

      expect(page).to have_content "Dossier updated"

      visit valuation_budget_budget_investments_path(budget)
      click_link investment.title

      within("#price") { expect(page).to have_content("12345") }
      within("#price_first_year") { expect(page).to have_content("9876") }
      expect(page).to have_content("Very cheap idea")
      within("#duration") { expect(page).to have_content("19 months") }
      within("#feasibility") { expect(page).to have_content("Feasible") }
      expect(page).not_to have_content("Valuation finished")
    end

    scenario "Feasibility can be marked as pending" do
      visit valuation_budget_budget_investment_path(budget, investment)
      click_link "Edit dossier"

      expect(find("#budget_investment_feasibility_undecided")).to be_checked
      choose "budget_investment_feasibility_feasible"
      click_button "Save changes"

      visit edit_valuation_budget_budget_investment_path(budget, investment)

      expect(find("#budget_investment_feasibility_undecided")).not_to be_checked
      expect(find("#budget_investment_feasibility_feasible")).to be_checked

      choose "budget_investment_feasibility_undecided"
      click_button "Save changes"

      visit edit_valuation_budget_budget_investment_path(budget, investment)
      expect(find("#budget_investment_feasibility_undecided")).to be_checked
    end

    scenario "Feasibility selection makes proper fields visible" do
      feasible_fields = ["Price (€)", "Cost during the first year (€)", "Price explanation",
                         "Time scope"]
      unfeasible_fields = ["Feasibility explanation"]
      any_feasibility_fields = ["Valuation finished"]
      undecided_fields = feasible_fields + unfeasible_fields + any_feasibility_fields

      visit edit_valuation_budget_budget_investment_path(budget, investment)

      expect(find("#budget_investment_feasibility_undecided")).to be_checked

      undecided_fields.each do |field|
        expect(page).to have_content(field)
      end

      choose "budget_investment_feasibility_feasible"

      unfeasible_fields.each do |field|
        expect(page).not_to have_content(field)
      end

      (feasible_fields + any_feasibility_fields).each do |field|
        expect(page).to have_content(field)
      end

      choose "budget_investment_feasibility_unfeasible"

      feasible_fields.each do |field|
        expect(page).not_to have_content(field)
      end

      (unfeasible_fields + any_feasibility_fields).each do |field|
        expect(page).to have_content(field)
      end

      click_button "Save changes"

      visit edit_valuation_budget_budget_investment_path(budget, investment)

      expect(find("#budget_investment_feasibility_unfeasible")).to be_checked
      feasible_fields.each do |field|
        expect(page).not_to have_content(field)
      end

      (unfeasible_fields + any_feasibility_fields).each do |field|
        expect(page).to have_content(field)
      end

      choose "budget_investment_feasibility_undecided"

      undecided_fields.each do |field|
        expect(page).to have_content(field)
      end
    end

    scenario "Dossier hide price on hide money budgets" do
      budget = create(:budget, :valuating, :hide_money)
      investment = create(:budget_investment, budget: budget, administrator: admin, valuators: [valuator])
      investment.update!(visible_to_valuators: true)

      visit valuation_budget_budget_investments_path(budget)
      within("#budget_investment_#{investment.id}") do
        click_link "Edit dossier"
      end

      expect(page).not_to have_content "Price (€)"
      expect(page).not_to have_content "Cost during the first year (€)"
      expect(page).not_to have_content "Price explanation"

      choose  "budget_investment_feasibility_feasible"
      fill_in "budget_investment_duration", with: "12 months"
      click_button "Save changes"

      expect(page).to have_content "Dossier updated"

      visit valuation_budget_budget_investments_path(budget)
      click_link investment.title

      within("#duration") { expect(page).to have_content("12 months") }
      within("#feasibility") { expect(page).to have_content("Feasible") }
      expect(page).not_to have_selector "#price"
      expect(page).not_to have_selector "#price_first_year"
    end

    scenario "Finish valuation" do
      investment.update!(visible_to_valuators: true)

      visit valuation_budget_budget_investment_path(budget, investment)
      click_link "Edit dossier"

      accept_confirm { find_field("budget_investment[valuation_finished]").click }
      click_button "Save changes"

      expect(page).to have_content "Dossier updated"

      visit valuation_budget_budget_investments_path(budget)
      expect(page).not_to have_content investment.title
      click_link "Valuation finished"

      expect(page).to have_content investment.title
      click_link investment.title
      expect(page).to have_content("Valuation finished")
    end

    context "Reopen valuation" do
      before do
        investment.update(
          valuation_finished: true,
          feasibility: "feasible",
          unfeasibility_explanation: "Explanation is explanatory",
          price: 999,
          price_first_year: 666,
          price_explanation: "Democracy is not cheap",
          duration: "1 light year"
        )
      end

      scenario "Admins can reopen & modify finished valuation" do
        logout
        login_as(admin.user)
        visit edit_valuation_budget_budget_investment_path(budget, investment)

        within_fieldset "Feasibility" do
          expect(page).to have_field "Undefined", type: :radio
          expect(page).to have_field "Feasible", type: :radio

          choose "Unfeasible"
        end

        expect(page).to have_field "Feasibility explanation", type: :textarea
        expect(page).to have_field "Valuation finished", type: :checkbox
        expect(page).to have_button "Save changes"
      end

      scenario "Valuators that are not admins cannot reopen or modify a finished valuation" do
        visit edit_valuation_budget_budget_investment_path(budget, investment)

        expect(page).not_to have_selector("input[id='budget_investment_feasibility_undecided']")
        expect(page).not_to have_selector("textarea[id='budget_investment_unfeasibility_explanation']")
        expect(page).not_to have_selector("input[name='budget_investment[valuation_finished]']")
        expect(page).to have_content("Valuation finished")
        expect(page).to have_content("Feasibility: Feasible")
        expect(page).to have_content("Feasibility explanation: Explanation is explanatory")
        expect(page).to have_content("Price (€): 999")
        expect(page).to have_content("Cost during the first year: 666")
        expect(page).to have_content("Price explanation: Democracy is not cheap")
        expect(page).to have_content("Time scope: 1 light year")
        expect(page).not_to have_button("Save changes")
      end
    end

    scenario "Validates price formats on the server side", :no_js do
      investment.update!(visible_to_valuators: true)

      visit edit_valuation_budget_budget_investment_path(budget, investment)

      fill_in "Price (€)", with: "12345,98"
      fill_in "Cost during the first year (€) (optional, data not public)", with: "9876.6"
      click_button "Save changes"

      expect(page).to have_content("2 errors")
      expect(page).to have_content("Only integer numbers", count: 2)
    end

    scenario "not visible to valuators when budget is not valuating" do
      budget.update!(phase: "publishing_prices")

      investment = create(:budget_investment, budget: budget, valuators: [valuator])

      login_as(valuator.user)
      visit edit_valuation_budget_budget_investment_path(budget, investment)

      expect(page).to have_content("Investments can only be valuated when Budget is in valuating phase")
    end

    scenario "visible to admins regardless of not being in valuating phase" do
      budget.update!(phase: "publishing_prices")

      user = create(:user)
      admin = create(:administrator, user: user)
      valuator = create(:valuator, user: user)

      investment = create(:budget_investment, budget: budget, valuators: [valuator])

      login_as(admin.user)
      visit valuation_budget_budget_investment_path(budget, investment)
      click_link "Edit dossier"

      expect(page).to have_content investment.title
    end
  end
end
