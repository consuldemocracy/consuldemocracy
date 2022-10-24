require "rails_helper"

describe Budgets::InvestmentComponent do
  before { sign_in(create(:user)) }

  it "shows the investment image when defined" do
    investment = create(:budget_investment, :with_image)
    render_inline Budgets::InvestmentComponent.new(investment)

    expect(page).not_to have_css "img[src*='budget_investment_no_image']"
    expect(page).to have_css "img[alt='#{investment.image.title}']"
  end

  context "investment without an image" do
    let(:component) { Budgets::InvestmentComponent.new(create(:budget_investment)) }

    it "shows the default image" do
      render_inline component

      expect(page).to have_css "img[src*='budget_investment_no_image']"
    end

    it "shows a custom default image when available" do
      stub_const("#{SiteCustomization::Image}::VALID_IMAGES", { "budget_investment_no_image" => [260, 80] })
      create(:site_customization_image,
             name: "budget_investment_no_image",
             image: fixture_file_upload("logo_header-260x80.png"))

      render_inline component

      expect(page).to have_css "img[src$='logo_header-260x80.png']"
      expect(page).not_to have_css "img[src*='budget_investment_no_image']"
    end
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
