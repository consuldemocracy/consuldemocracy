require "rails_helper"

describe "Votes" do
  let!(:verified)   { create(:user, verified_at: Time.current) }
  let!(:unverified) { create(:user) }

  describe "Debates" do
    before { login_as(verified) }

    describe "Single debate" do
      scenario "Show" do
        debate = create(:debate)
        create(:vote, voter: verified, votable: debate, vote_flag: true)
        create(:vote, voter: unverified, votable: debate, vote_flag: false)

        visit debate_path(debate)

        expect(page).to have_content "2 votes"

        within(".in-favor") do
          expect(page).to have_content "50%"
          expect(page).to have_css("button.voted")
        end

        within(".against") do
          expect(page).to have_content "50%"
          expect(page).to have_css("button.no-voted")
        end
      end
    end
  end
end
