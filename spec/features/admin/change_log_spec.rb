require "rails_helper"

describe "Admin change log" do
  let(:budget) {create(:budget)}
  let(:administrator) do
    create(:administrator, user: create(:user, username: "Ana", email: "ana@admins.org"))
  end

  context "Investments Participatory Budgets" do

    before do
      @admin = create(:administrator)
      login_as(@admin.user)
    end

    scenario "No changes" do
      budget_investment = create(:budget_investment,
                                 price: 1234,
                                 price_first_year: 1000,
                                 feasibility: "unfeasible",
                                 unfeasibility_explanation: "It is impossible",
                                 administrator: administrator)

      visit admin_budget_budget_investments_path(budget_investment.budget)

      click_link budget_investment.title

      expect(page).to have_content(budget_investment.title)
      expect(page).to have_content(budget_investment.description)
      expect(page).to have_content(budget_investment.author.name)
      expect(page).to have_content(budget_investment.heading.name)
      expect(page).to have_content("There are not changes logged")
    end

    scenario "Changes" do
      budget_investment = create(:budget_investment,
                                 price: 1234,
                                 price_first_year: 1000,
                                 feasibility: "unfeasible",
                                 unfeasibility_explanation: "It is impossible",
                                 administrator: administrator)

      visit admin_budget_budget_investments_path(budget_investment.budget)

      click_link budget_investment.title

      expect(page).to have_content(budget_investment.title)
      expect(page).to have_content(budget_investment.description)
      expect(page).to have_content(budget_investment.author.name)
      expect(page).to have_content(budget_investment.heading.name)
      expect(page).to have_content("There are not changes logged")

      budget_investment.update(title: "test")

      visit admin_budget_budget_investments_path(budget_investment.budget)

      click_link budget_investment.title

      expect(page).not_to have_content("There are not changes logged")
      expect(page).to have_content("Change Log")
      expect(page).to have_content("Title")
      expect(page).to have_content("test")
      expect(page).to have_content("Field")
      expect(page).to have_content("Old Value")
      expect(page).to have_content("New Value")
      expect(page).to have_content("Edited at")
      expect(page).to have_content("Edited by")
    end

  end
end
