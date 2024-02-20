require "rails_helper"

describe "Emails" do
  before do
    reset_mailer
  end

  context "Budgets" do
    let(:author) { create(:user, :level_two) }
    let(:budget) { create(:budget) }
    before { create(:budget_heading, name: "More hospitals", budget: budget) }

    scenario "Investment created" do
      login_as(author)
      visit new_budget_investment_path(budget_id: budget.id)

      fill_in_new_investment_title with: "Build a hospital"
      fill_in_ckeditor "Description", with: "We have lots of people that require medical attention"

      click_button "Create Investment"
      expect(page).to have_content "Investment created successfully"

      email = open_last_email

      expect(email).to have_subject("Thank you for creating an investment!")
      expect(email).to deliver_to(author.email)
      expect(email).to have_body_text(author.name)
      expect(email).to have_body_text("Build a hospital")
      expect(email).to have_body_text(budget.name)
      expect(email).to have_body_text(budget_path(budget))
    end

    scenario "Unfeasible investment" do
      budget.update!(phase: "valuating")
      valuator = create(:valuator)
      investment = create(:budget_investment, author: author, budget: budget, valuators: [valuator])

      login_as(valuator.user)
      visit edit_valuation_budget_budget_investment_path(budget, investment)

      within_fieldset("Feasibility") { choose "Unfeasible" }
      fill_in "Unfeasibility explanation", with: "This is not legal as stated in Article 34.9"
      accept_confirm { check "Valuation finished" }
      click_button "Save changes"

      expect(page).to have_content "Dossier updated"

      email = open_last_email
      expect(email).to have_subject("Your investment project '#{investment.code}' has been marked as unfeasible")
      expect(email).to deliver_to(investment.author.email)
      expect(email).to have_body_text "This is not legal as stated in Article 34.9"
    end
  end
end
