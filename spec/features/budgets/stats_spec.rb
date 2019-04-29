require "rails_helper"

feature "Stats" do

  let(:budget)  { create(:budget) }
  let(:group)   { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group, price: 1000) }

  describe "Show" do
  end

end
