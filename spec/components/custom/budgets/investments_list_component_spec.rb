require "rails_helper"

describe Budgets::InvestmentsListComponent do
  include Rails.application.routes.url_helpers

  let(:budget)    { create(:budget, :accepting) }
  let(:group)     { create(:budget_group, budget: budget) }
  let(:heading)   { create(:budget_heading, group: group) }

  describe "link to see all investments" do
    before { create_list(:budget_investment, 3, :selected, heading: heading, price: 999) }

    it "is shown in all other phases" do
      (Budget::Phase::PHASE_KINDS - %w[informing finished]).each do |phase_name|
        budget.phase = phase_name

        render_inline Budgets::InvestmentsListComponent.new(budget)

        expect(page).to have_link "See all investments",
                                  href: budget_investments_path(budget, heading_id: heading.id)
      end
    end
  end
end
