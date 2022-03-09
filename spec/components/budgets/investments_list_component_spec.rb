require "rails_helper"

describe Budgets::InvestmentsListComponent do
  include Rails.application.routes.url_helpers

  let(:budget)    { create(:budget, :accepting) }
  let(:group)     { create(:budget_group, budget: budget) }
  let(:heading)   { create(:budget_heading, group: group) }

  describe "#investments" do
    let(:component) { Budgets::InvestmentsListComponent.new(budget) }

    let!(:normal_investments)   { create_list(:budget_investment, 4, heading: heading) }
    let!(:feasible_investments) { create_list(:budget_investment, 4, :feasible, heading: heading) }
    let!(:selected_investments) { create_list(:budget_investment, 4, :selected, heading: heading) }

    it "returns an empty relation if phase is informing or finished" do
      %w[informing finished].each do |phase_name|
        budget.phase = phase_name

        expect(component.investments).to be_empty
      end
    end

    it "returns a maximum 9 investments by default" do
      expect(budget.investments.count).to be 12
      expect(component.investments.count).to be 9
    end

    it "returns a different random array of investments every time" do
      expect(component.investments(limit: 7)).not_to eq component.investments(limit: 7)
    end

    it "returns any investments while accepting and reviewing" do
      %w[accepting reviewing].each do |phase_name|
        budget.phase = phase_name

        investments = component.investments(limit: 9)

        expect(investments & normal_investments).not_to be_empty
        expect(investments & feasible_investments).not_to be_empty
        expect(investments & selected_investments).not_to be_empty
      end
    end

    it "returns only feasible investments if phase is selecting, valuating or publishing_prices" do
      %w[selecting valuating publishing_prices].each do |phase_name|
        budget.phase = phase_name

        investments = component.investments(limit: 6)

        expect(feasible_investments + selected_investments).to include(*investments)
      end
    end

    it "returns only selected investments if phase is balloting or reviewing_ballots" do
      %w[balloting reviewing_ballots].each do |phase_name|
        budget.phase = phase_name

        investments = component.investments(limit: 3)

        expect(selected_investments).to include(*investments)
      end
    end
  end

  describe "investment list" do
    before { create_list(:budget_investment, 3, :selected, heading: heading, price: 999) }

    it "is not shown in the informing or finished phases" do
      %w[informing finished].each do |phase_name|
        budget.phase = phase_name

        render_inline Budgets::InvestmentsListComponent.new(budget)

        expect(page).not_to have_content "List of investments"
        expect(page).not_to have_css ".investments-list"
        expect(page).not_to have_css ".budget-investment"
      end
    end

    it "is shown without supports nor prices in the accepting phases" do
      %w[accepting reviewing selecting].each do |phase_name|
        budget.phase = phase_name

        render_inline Budgets::InvestmentsListComponent.new(budget)

        expect(page).to have_content "List of investments"
        expect(page).not_to have_content "Supports"
        expect(page).not_to have_content "Price"
      end
    end

    it "is shown with supports in the valuating phase" do
      budget.phase = "valuating"

      render_inline Budgets::InvestmentsListComponent.new(budget)

      expect(page).to have_content "List of investments"
      expect(page).to have_content "Supports", count: 3
      expect(page).not_to have_content "Price"
    end

    it "is shown with prices in the balloting phases" do
      %w[publishing_prices balloting reviewing_ballots].each do |phase_name|
        budget.phase = phase_name

        render_inline Budgets::InvestmentsListComponent.new(budget)

        expect(page).to have_content "List of investments"
        expect(page).to have_content "Price", count: 3
        expect(page).not_to have_content "Supports"
      end
    end

    it "is rendered for budgets with multiple headings" do
      create(:budget_heading, budget: budget)

      (Budget::Phase::PHASE_KINDS - %w[informing finished]).each do |phase_name|
        budget.phase = phase_name

        render_inline Budgets::InvestmentsListComponent.new(budget)

        expect(page).to have_content "List of investments"
      end
    end
  end

  describe "link to see all investments" do
    before { create_list(:budget_investment, 3, :selected, heading: heading, price: 999) }

    it "is not shown in the informing phase" do
      budget.phase = "informing"

      render_inline Budgets::InvestmentsListComponent.new(budget)

      expect(page).not_to have_link "See all investments"
    end

    it "is shown in all other phases" do
      (Budget::Phase::PHASE_KINDS - ["informing"]).each do |phase_name|
        budget.phase = phase_name

        render_inline Budgets::InvestmentsListComponent.new(budget)

        expect(page).to have_link "See all investments",
                                  href: budget_investments_path(budget)
      end
    end

    context "budget with multiple headings" do
      before { create(:budget_heading, budget: budget) }

      it "is not shown in the informing or finished phases" do
        %w[informing finished].each do |phase_name|
          budget.phase = phase_name

          render_inline Budgets::InvestmentsListComponent.new(budget)

          expect(page).not_to have_link "See all investments"
        end
      end

      it "is shown in all other phases" do
        (Budget::Phase::PHASE_KINDS - %w[informing finished]).each do |phase_name|
          budget.phase = phase_name

          render_inline Budgets::InvestmentsListComponent.new(budget)

          expect(page).to have_link "See all investments",
                                    href: budget_groups_path(budget)
        end
      end
    end
  end
end
