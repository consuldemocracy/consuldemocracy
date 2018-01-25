require 'rails_helper'

feature 'Groups' do

  let(:user)   { create(:user, :level_two) }
  let(:budget) { create(:budget) }
  let(:group)  { create(:budget_group, budget: budget) }

  context 'show' do

    scenario "group not found raises 404 error" do
      expect { visit budget_group_path('s', 'n') }.to raise_error(ActionController::RoutingError)
    end

    scenario "Budget correctly found" do
      visit budget_group_path(budget.id, group.id)

      expect(page.status_code).to eq 200
    end

    scenario "Group correctly found" do
      visit budget_group_path(group.budget.id, group.id)

      expect(page.status_code).to eq 200
    end

  end

end
