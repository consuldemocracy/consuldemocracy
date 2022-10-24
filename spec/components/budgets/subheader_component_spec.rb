require "rails_helper"

describe Budgets::SubheaderComponent do
  it "shows budget current phase name" do
    sign_in(create(:user))
    budget = create(:budget, :informing)

    render_inline Budgets::SubheaderComponent.new(budget)

    page.find(".budget-subheader") do |subheader|
      expect(subheader).to have_content "Current phase"
      expect(subheader).to have_content "Information"
    end
  end

  describe "when budget is accepting" do
    let(:budget) { create(:budget, :accepting) }

    it "and user is level_two_or_three_verified shows a link to create a new investment" do
      sign_in(create(:user, :level_two))

      render_inline Budgets::SubheaderComponent.new(budget)

      expect(page).to have_link "Create a budget investment"

      (Budget::Phase::PHASE_KINDS - ["accepting"]).each do |phase|
        budget.update!(phase: phase)
        budget.reload

        render_inline Budgets::SubheaderComponent.new(budget)

        expect(page).not_to have_link "Create a budget investment"
      end
    end

    it "and user is not verified shows a link to account verification" do
      sign_in(create(:user))

      render_inline Budgets::SubheaderComponent.new(budget)

      expect(page).to have_content "To create a new budget investment"
      expect(page).to have_link "verify your account"

      (Budget::Phase::PHASE_KINDS - ["accepting"]).each do |phase|
        budget.update!(phase: phase)
        budget.reload

        render_inline Budgets::SubheaderComponent.new(budget)

        expect(page).not_to have_content "To create a new budget investment"
        expect(page).not_to have_link "verify your account"
      end
    end

    it "and user is not logged in shows links to sign in and sign up" do
      render_inline Budgets::SubheaderComponent.new(budget)

      expect(page).to have_content "To create a new budget investment you must"
      expect(page).to have_link "sign in"
      expect(page).to have_link "sign up"

      (Budget::Phase::PHASE_KINDS - ["accepting"]).each do |phase|
        budget.update!(phase: phase)
        budget.reload

        render_inline Budgets::SubheaderComponent.new(budget)

        expect(page).not_to have_content "To create a new budget investment you must"
        expect(page).not_to have_link "sign in"
        expect(page).not_to have_link "sign up"
      end
    end
  end

  describe "See results link" do
    it "is showed when budget is finished and results are enabled for all users" do
      budget = create(:budget, :finished)
      sign_in(create(:user))
      render_inline Budgets::SubheaderComponent.new(budget)

      expect(page).to have_link "See results"

      sign_in(create(:administrator).user)
      render_inline Budgets::SubheaderComponent.new(budget)

      expect(page).to have_link "See results"
    end

    it "is not showed when budget is finished or results are disabled for all users" do
      budget = create(:budget, :balloting, results_enabled: true)
      sign_in(create(:user))
      render_inline Budgets::SubheaderComponent.new(budget)

      expect(page).not_to have_link "See results"

      sign_in(create(:administrator).user)
      render_inline Budgets::SubheaderComponent.new(budget)

      expect(page).not_to have_link "See results"
    end
  end
end
