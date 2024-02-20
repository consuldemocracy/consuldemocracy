require "rails_helper"

describe "Valuation budget investments" do
  let(:budget) { create(:budget, :valuating) }
  let(:valuator) do
    create(:valuator, user: create(:user, username: "Rachel", email: "rachel@valuators.org"))
  end

  before do
    login_as(valuator.user)
  end

  describe "Valuate" do
    let(:admin) { create(:administrator) }
    let(:investment) do
      create(:budget_investment, budget: budget, price: nil, administrator: admin, valuators: [valuator])
    end

    scenario "Can valuate investments for more than one active budgets" do
      budget1 = create(:budget, :valuating)
      budget2 = create(:budget, :valuating)
      investment1 = create(:budget_investment, :visible_to_valuators, budget: budget1, valuators: [valuator])
      investment2 = create(:budget_investment, :visible_to_valuators, budget: budget2, valuators: [valuator])

      visit valuation_budgets_path
      within "#budget_#{budget1.id}" do
        click_link "Evaluate"
      end

      click_link "Edit dossier"
      expect(page).to have_content "Dossier"
      expect(page).to have_content investment1.title

      visit valuation_budgets_path
      within "#budget_#{budget2.id}" do
        click_link "Evaluate"
      end

      click_link "Edit dossier"
      expect(page).to have_content "Dossier"
      expect(page).to have_content investment2.title
    end

    scenario "Feasibility selection makes proper fields visible" do
      feasible_fields = ["Price (€)", "Cost during the first year (€)", "Price explanation",
                         "Feasibility explanation", "Time scope"]
      unfeasible_fields = ["Unfeasibility explanation"]
      any_feasibility_fields = ["Valuation finished"]
      undecided_fields = feasible_fields - unfeasible_fields + any_feasibility_fields

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

        expect(page).to have_field "Unfeasibility explanation", type: :textarea
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
        expect(page).to have_content("Feasibility explanation")
        expect(page).to have_content("Unfeasibility explanation: Explanation is explanatory")
        expect(page).to have_content("Price (€): 999")
        expect(page).to have_content("Cost during the first year: 666")
        expect(page).to have_content("Price explanation: Democracy is not cheap")
        expect(page).to have_content("Time scope: 1 light year")
        expect(page).not_to have_button("Save changes")
      end
    end
  end
end
