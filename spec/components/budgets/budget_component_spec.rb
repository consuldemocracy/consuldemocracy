require "rails_helper"

describe Budgets::BudgetComponent, type: :component do
  let(:budget) { create(:budget) }
  let(:heading) { create(:budget_heading, budget: budget) }
  let(:user) { create(:user) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "budget header" do
    it "shows budget name and link to help" do
      budget.update!(phase: "informing")

      render_inline Budgets::BudgetComponent.new(budget)

      within(".budget-header") do
        expect(page).to have_content("PARTICIPATORY BUDGETS")
        expect(page).to have_content(budget.name)
        expect(page).to have_link("Help with participatory budgets")
      end
    end

    it "shows budget main link when defined" do
      render_inline Budgets::BudgetComponent.new(budget)

      within(".budget-header") do
        expect(page).not_to have_css("a.main-link")
      end

      budget.update!(main_link_text: "Partitipate now!", main_link_url: "https://consulproject.org")

      render_inline Budgets::BudgetComponent.new(budget)

      within(".budget-header") do
        expect(page).to have_css("a.main-link", text: "Participate now!", href: "https://consulproject.org")
      end
    end
  end

  describe "map" do
    before do
      Setting["feature.map"] = true
    end

    it "displays investment's map location markers" do
      investment1 = create(:budget_investment, heading: heading)
      investment2 = create(:budget_investment, heading: heading)
      investment3 = create(:budget_investment, heading: heading)

      create(:map_location, longitude: 40.1234, latitude: -3.634, investment: investment1)
      create(:map_location, longitude: 40.1235, latitude: -3.635, investment: investment2)
      create(:map_location, longitude: 40.1236, latitude: -3.636, investment: investment3)

      render_inline Budgets::BudgetComponent.new(budget)

      within ".map_location" do
        expect(page).to have_css(".map-icon", count: 3)
      end
    end

    it "displays all investment's map location if there are no selected" do
      budget.update!(phase: :publishing_prices)

      investment1 = create(:budget_investment, heading: heading)
      investment2 = create(:budget_investment, heading: heading)
      investment3 = create(:budget_investment, heading: heading)
      investment4 = create(:budget_investment, heading: heading)

      investment1.create_map_location(longitude: 40.1234, latitude: 3.1234, zoom: 10)
      investment2.create_map_location(longitude: 40.1235, latitude: 3.1235, zoom: 10)
      investment3.create_map_location(longitude: 40.1236, latitude: 3.1236, zoom: 10)
      investment4.create_map_location(longitude: 40.1240, latitude: 3.1240, zoom: 10)

      render_inline Budgets::BudgetComponent.new(budget)

      within ".map_location" do
        expect(page).to have_css(".map-icon", count: 4)
      end
    end

    it "displays only selected investment's map location from publishing prices phase" do
      budget.update!(phase: :publishing_prices)

      investment1 = create(:budget_investment, :selected, heading: heading)
      investment2 = create(:budget_investment, :selected, heading: heading)
      investment3 = create(:budget_investment, heading: heading)
      investment4 = create(:budget_investment, heading: heading)

      investment1.create_map_location(longitude: 40.1234, latitude: 3.1234, zoom: 10)
      investment2.create_map_location(longitude: 40.1235, latitude: 3.1235, zoom: 10)
      investment3.create_map_location(longitude: 40.1236, latitude: 3.1236, zoom: 10)
      investment4.create_map_location(longitude: 40.1240, latitude: 3.1240, zoom: 10)

      render_inline Budgets::BudgetComponent.new(budget)

      within ".map_location" do
        expect(page).to have_css(".map-icon", count: 2)
      end
    end

    scenario "skips invalid map markers" do
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

      allow_any_instance_of(Budgets::BudgetComponent).to receive(:coordinates).and_return(coordinates)

      render_inline Budgets::BudgetComponent.new(budget)

      within ".map_location" do
        expect(page).to have_css(".map-icon", count: 1)
      end
    end
  end
end
