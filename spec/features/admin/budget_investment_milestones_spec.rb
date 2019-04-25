require "rails_helper"

describe "Admin budget investment milestones" do

  it_behaves_like "edit_translatable",
                  "milestone",
                  "edit_tracking_budget_budget_investment_milestone_path",
                  %w[description]
end
