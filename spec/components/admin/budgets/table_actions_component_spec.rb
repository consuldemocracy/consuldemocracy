require "rails_helper"

describe Admin::Budgets::TableActionsComponent, controller: Admin::BaseController do
  let(:budget) { create(:budget) }
  let(:component) { Admin::Budgets::TableActionsComponent.new(budget) }

  it "renders actions to edit budget and manage investments" do
    render_inline component

    expect(page).to have_link count: 2
    expect(page).to have_link "Investment projects", href: /investments/
    expect(page).to have_link "Edit", href: /#{budget.id}\Z/

    expect(page).not_to have_button
  end
end
