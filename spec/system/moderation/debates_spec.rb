require "rails_helper"

describe "Moderate debates" do
  describe "/moderation/ screen" do
    before do
      moderator = create(:moderator)
      login_as(moderator.user)
    end

    scenario "Filtering debates" do
      create(:debate, title: "Regular debate")
      create(:debate, :flagged, title: "Pending debate")
      create(:debate, :hidden, title: "Hidden debate")
      create(:debate, :flagged, :with_ignored_flag, title: "Ignored debate")

      visit moderation_debates_path(filter: "all")
      expect(page).to have_content("Regular debate")
      expect(page).to have_content("Pending debate")
      expect(page).not_to have_content("Hidden debate")
      expect(page).to have_content("Ignored debate")

      visit moderation_debates_path(filter: "pending_flag_review")
      expect(page).not_to have_content("Regular debate")
      expect(page).to have_content("Pending debate")
      expect(page).not_to have_content("Hidden debate")
      expect(page).not_to have_content("Ignored debate")

      visit moderation_debates_path(filter: "with_ignored_flag")
      expect(page).not_to have_content("Regular debate")
      expect(page).not_to have_content("Pending debate")
      expect(page).not_to have_content("Hidden debate")
      expect(page).to have_content("Ignored debate")
    end

    scenario "sorting debates" do
      flagged_debate = create(:debate,
                              title: "Flagged debate",
                              created_at: 1.day.ago,
                              flags_count: 5)
      flagged_new_debate = create(:debate,
                                  title: "Flagged new debate",
                                  created_at: 12.hours.ago,
                                  flags_count: 3)
      newer_debate = create(:debate, title: "Newer debate", created_at: Time.current)

      visit moderation_debates_path(order: "created_at")

      expect(flagged_new_debate.title).to appear_before(flagged_debate.title)

      visit moderation_debates_path(order: "flags")

      expect(flagged_debate.title).to appear_before(flagged_new_debate.title)

      visit moderation_debates_path(filter: "all", order: "created_at")

      expect(newer_debate.title).to appear_before(flagged_new_debate.title)
      expect(flagged_new_debate.title).to appear_before(flagged_debate.title)

      visit moderation_debates_path(filter: "all", order: "flags")

      expect(flagged_debate.title).to appear_before(flagged_new_debate.title)
      expect(flagged_new_debate.title).to appear_before(newer_debate.title)
    end
  end
end
