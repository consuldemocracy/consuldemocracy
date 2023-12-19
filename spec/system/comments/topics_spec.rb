require "rails_helper"

describe "Commenting topics from proposals" do
  let(:proposal) { create(:proposal) }

  it_behaves_like "flaggable", :topic_with_community_comment

  describe "Voting comments" do
    let(:verified)   { create(:user, verified_at: Time.current) }
    let(:unverified) { create(:user) }
    let(:proposal)   { create(:proposal) }
    let(:topic)      { create(:topic, community: proposal.community) }
    let!(:comment)   { create(:comment, commentable: topic) }

    before do
      login_as(verified)
    end

    scenario "Update" do
      visit community_topic_path(proposal.community, topic)

      within("#comment_#{comment.id}_votes") do
        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "1"
        end

        click_button "I disagree"

        within(".in-favor") do
          expect(page).to have_content "0"
        end

        within(".against") do
          expect(page).to have_content "1"
        end

        expect(page).to have_content "1 vote"
      end
    end

    scenario "Allow undoing votes" do
      visit community_topic_path(proposal.community, topic)

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

describe "Commenting topics from budget investments" do
  let(:user)       { create(:user) }
  let(:investment) { create(:budget_investment) }

  describe "Voting comments" do
    let(:verified)   { create(:user, verified_at: Time.current) }
    let(:unverified) { create(:user) }
    let(:investment) { create(:budget_investment) }
    let(:topic)      { create(:topic, community: investment.community) }
    let!(:comment)   { create(:comment, commentable: topic) }

    before do
      login_as(verified)
    end

    scenario "Update" do
      visit community_topic_path(investment.community, topic)

      within("#comment_#{comment.id}_votes") do
        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "1"
        end

        click_button "I disagree"

        within(".in-favor") do
          expect(page).to have_content "0"
        end

        within(".against") do
          expect(page).to have_content "1"
        end

        expect(page).to have_content "1 vote"
      end
    end

    scenario "Allow undoing votes" do
      visit community_topic_path(investment.community, topic)

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
