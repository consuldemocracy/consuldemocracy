require "rails_helper"

describe "investment row" do
  it "uses a JSON request to update visible to valuators" do
    investment = create(:budget_investment)
    @budget = investment.budget
    sign_in(create(:administrator).user)

    render "admin/budget_investments/select_investment", investment: investment

    expect(rendered).to have_css "form[action$='json'] input[name$='[visible_to_valuators]']"
  end
end
