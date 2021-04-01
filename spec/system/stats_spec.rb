require "rails_helper"

describe "Stats" do
  context "Summary" do
    scenario "General" do
      create(:debate)
      2.times { create(:proposal) }
      3.times { create(:comment, commentable: Debate.first) }
      4.times { create(:visit) }

      visit stats_path

      expect(page).to have_content "DEBATES\n1"
      expect(page).to have_content "PROPOSALS\n2"
      expect(page).to have_content "COMMENTS\n3"
      expect(page).to have_content "VISITS\n4"
    end

    scenario "Votes" do
      create(:debate,   voters: Array.new(1) { create(:user) })
      create(:proposal, voters: Array.new(2) { create(:user) })
      create(:comment,  voters: Array.new(3) { create(:user) })

      visit stats_path

      expect(page).to have_content "VOTES ON DEBATES\n1"
      expect(page).to have_content "VOTES ON PROPOSALS\n2"
      expect(page).to have_content "VOTES ON COMMENTS\n3"
      expect(page).to have_content "TOTAL VOTES\n6"
    end

    scenario "Users" do
      1.times { create(:user, :level_three) }
      2.times { create(:user, :level_two) }
      2.times { create(:user) }

      visit stats_path

      expect(page).to have_content "VERIFIED USERS\n3"
      expect(page).to have_content "UNVERIFIED USERS\n2"
    end
  end
end
