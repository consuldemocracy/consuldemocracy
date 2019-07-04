require "rails_helper"

feature "Admin budget investment milestones" do

  it_behaves_like "translatable",
                  "milestone",
                  "edit_admin_budget_budget_investment_milestone_path",
                  %w[description]
end
