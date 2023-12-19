require "rails_helper"

describe "Commenting proposals" do
  let(:proposal) { create(:proposal) }

  it_behaves_like "flaggable", :proposal_comment

  describe "Voting comments" do
    let(:verified)   { create(:user, verified_at: Time.current) }
    let(:unverified) { create(:user) }
    let(:proposal)   { create(:proposal) }
    let!(:comment)   { create(:comment, commentable: proposal) }

    before do
      login_as(verified)
    end

    scenario "Allow undoing votes" do
      visit proposal_path(proposal)

      within("#comment_#{comment.id}_votes") do
        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "1"
        end

        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "0"
        end

        within(".against") do
          expect(page).to have_content "0"
        end

        expect(page).to have_content "No votes"
      end
    end
  end
end
