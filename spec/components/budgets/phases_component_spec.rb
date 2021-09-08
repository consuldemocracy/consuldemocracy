require "rails_helper"

describe Budgets::PhasesComponent do
  let(:budget) { create(:budget) }

  it "shows budget current phase main link when defined" do
    render_inline Budgets::PhasesComponent.new(budget)

    expect(page).not_to have_css(".main-link")

    budget.current_phase.update!(main_link_text: "Phase link!", main_link_url: "https://consulproject.org")
    render_inline Budgets::PhasesComponent.new(budget)

    expect(page).to have_css(".main-link")
    expect(page).to have_link("Phase link!", href: "https://consulproject.org")
  end
end
