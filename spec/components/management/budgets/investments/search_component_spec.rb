require "rails_helper"

describe Management::Budgets::Investments::SearchComponent do
  let(:budget) { create(:budget) }
  let(:component) { Management::Budgets::Investments::SearchComponent.new(budget, action: :index) }

  it "renders a label for each field" do
    render_inline component

    expect(page).to have_field "Search investments"
    expect(page).to have_select "Heading"
    expect(page).to have_field "Search unfeasible", type: :checkbox
  end
end
