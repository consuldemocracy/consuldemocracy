require "rails_helper"

describe Admin::Budgets::LinksComponent, controller: Admin::BaseController do
  before { sign_in(create(:administrator).user) }

  describe "see results link" do
    let(:budget) { create(:budget, :finished) }
    let(:component) { Admin::Budgets::LinksComponent.new(budget) }

    it "is shown for budgets with results enabled" do
      budget.update!(results_enabled: true)

      render_inline component

      expect(page).to have_link "See results"
      expect(page).not_to have_link "Preview results"
    end

    it "is not shown for budgets with results disabled" do
      budget.update!(results_enabled: false)

      render_inline component

      expect(page).not_to have_link "See results"
      expect(page).not_to have_link "Preview results"
    end

    context "after calculating winners" do
      let(:budget) { create(:budget, :with_winner) }

      it "is shown as a preview link after finishing the process" do
        budget.update!(phase: "finished", results_enabled: false)

        render_inline component

        expect(page).to have_link "Preview results"
        expect(page).not_to have_link "See results"
      end

      it "is shown as a preview link after balloting has finished" do
        budget.update!(phase: "reviewing_ballots", results_enabled: false)

        render_inline component

        expect(page).to have_link "Preview results"
        expect(page).not_to have_link "See results"
        expect(page).not_to have_link "View"
        expect(page).not_to have_link "Preview"
      end

      it "is not shown while balloting" do
        budget.update!(phase: "balloting", results_enabled: true)

        render_inline component

        expect(page).not_to have_link "Preview results"
        expect(page).not_to have_link "See results"
      end
    end
  end

  describe "preview/view link" do
    it "shows a link to preview an unpublished budget" do
      budget = create(:budget, :drafting)

      render_inline Admin::Budgets::LinksComponent.new(budget)

      expect(page).to have_link "Preview"
      expect(page).not_to have_link "View"
    end

    it "shows a link to view a published budget" do
      budget = create(:budget, :informing)

      render_inline Admin::Budgets::LinksComponent.new(budget)

      expect(page).to have_link "View"
      expect(page).not_to have_link "Preview"
    end
  end

  describe "investments link" do
    let(:budget) { create(:budget) }
    let(:component) { Admin::Budgets::LinksComponent.new(budget) }

    it "is shown for budgets with investments" do
      create(:budget_investment, budget: budget)

      render_inline component

      expect(page).to have_link "Investment projects"
    end

    it "is not shown for budgets without investments" do
      render_inline component

      expect(page).not_to have_link "Investment projects"
    end
  end

  describe "ballots link" do
    let(:budget) { create(:budget) }
    let(:component) { Admin::Budgets::LinksComponent.new(budget) }

    it "is rendered for budgets with polls" do
      budget.poll = create(:poll, budget: budget)
      path = Rails.application.routes.url_helpers.admin_poll_booth_assignments_path(budget.poll)

      render_inline component

      expect(page).to have_link "Ballots", href: path
    end

    it "is not rendered for budgets without polls" do
      render_inline component

      expect(page).not_to have_link "Ballots"
    end
  end
end
