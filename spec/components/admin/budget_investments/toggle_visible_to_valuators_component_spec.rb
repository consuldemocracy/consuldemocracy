require "rails_helper"

describe Admin::BudgetInvestments::ToggleVisibleToValuatorsComponent, :admin do
  it "uses a JSON request to update visible to valuators" do
    render_inline Admin::BudgetInvestments::ToggleVisibleToValuatorsComponent.new(create(:budget_investment))

    expect(page).to have_css "form[action$='json'] input[name$='[visible_to_valuators]']"
  end
end
