require "rails_helper"

describe Budgets::InvestmentComponent do
  before { sign_in(create(:user)) }

  it "shows the investment image when defined" do
    investment = create(:budget_investment, :with_image)
    render_inline Budgets::InvestmentComponent.new(investment)

    expect(page).not_to have_css "img[src*='budget_investment_no_image']"
    expect(page).to have_css "img[alt='#{investment.image.title}']"
  end

  it "shows the default image when investment has not an image defined" do
    investment = create(:budget_investment)
    render_inline Budgets::InvestmentComponent.new(investment)

    expect(page).to have_css "img[src*='budget_investment_no_image']"
  end

  it "shows supports count when budget is valuating" do
    budget = create(:budget, :valuating)
    investment = create(:budget_investment, budget: budget)
    render_inline Budgets::InvestmentComponent.new(investment)

    expect(page).to have_content "Supports"

    budget.update!(phase: (Budget::Phase::PHASE_KINDS - ["valuating"]).sample)
    render_inline Budgets::InvestmentComponent.new(investment)

    expect(page).not_to have_content "Supports"
  end

  it "shows price when investment is selected and budget prices are published" do
    budget = create(:budget, :finished)
    investment = create(:budget_investment, :selected, budget: budget)
    render_inline Budgets::InvestmentComponent.new(investment)

    expect(page).to have_content "Price"

    budget.update!(phase: (Budget::Phase::PHASE_KINDS - Budget::Phase::PUBLISHED_PRICES_PHASES).sample)
    render_inline Budgets::InvestmentComponent.new(investment)

    expect(page).not_to have_content "Price"
  end

  it "shows investment information" do
    investment = create(:budget_investment)
    render_inline Budgets::InvestmentComponent.new(investment)

    expect(page).to have_link investment.title
    expect(page).to have_link "Read more"
    expect(page).to have_css ".investment-project-info"
  end
end
