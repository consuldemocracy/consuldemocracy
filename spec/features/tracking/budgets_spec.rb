require "rails_helper"

describe "Tracking budgets" do

  before do
    @tracker = create(:tracker, user: create(:user, username: "Rachel",
                                             email: "rachel@trackers.org"))
    login_as(@tracker.user)
  end

  scenario "Disabled with a feature flag" do
    Setting["process.budgets"] = nil
    expect{ visit tracking_budgets_path }.to raise_exception(FeatureFlags::FeatureDisabled)
  end

  context "Index" do

    scenario "Displaying budgets" do
      budget = create(:budget)
      visit tracking_budgets_path

      expect(page).to have_content(budget.name)
    end

    scenario "With no budgets" do
      visit tracking_budgets_path

      expect(page).to have_content "There are no budgets"
    end
  end

end
