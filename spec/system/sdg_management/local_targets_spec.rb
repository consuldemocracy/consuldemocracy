require "rails_helper"

describe "Local Targets", :js do
  before do
    login_as(create(:administrator).user)
    Setting["feature.sdg"] = true
  end

  describe "Index" do
    scenario "Visit the index" do
      create(:sdg_local_target, code: "1.1.1", title: "Affordable food")

      visit sdg_management_goals_path
      click_link "Local Targets"

      expect(page).to have_title "SDG content - Local Targets"
      within("table") { expect(page).to have_content "Affordable food for everyone" }
    end

    scenario "Show local targets grouped by target" do
      target_1 = SDG::Target["1.1"]
      target_1_local_target = create(:sdg_local_target, code: "1.1.1", target: target_1)
      target_2 = SDG::Target["2.1"]
      target_2_local_target = create(:sdg_local_target, code: "2.1.1", target: target_2)

      visit sdg_management_local_targets_path

      expect(target_1.title).to appear_before(target_1_local_target.title)
      expect(target_1_local_target.title).to appear_before(target_2.title)
      expect(target_2.title).to appear_before(target_2_local_target.title)
    end
  end
end
