require "rails_helper"

describe "Votes" do
  let!(:verified)   { create(:user, verified_at: Time.current) }
  let!(:unverified) { create(:user) }

  describe "Debates" do
    before { login_as(verified) }

    scenario "Index shows user votes on debates" do
      debate1 = create(:debate)
      debate2 = create(:debate)
      debate3 = create(:debate)
      create(:vote, voter: verified, votable: debate1, vote_flag: true)
      create(:vote, voter: verified, votable: debate3, vote_flag: false)

      visit debates_path

      within("#debates") do
        within("#debate_#{debate1.id}_votes") do
          within(".in-favor") do
            expect(page).to have_css("button.voted")
            expect(page).not_to have_css("button.no-voted")
          end

          within(".against") do
            expect(page).to have_css("button.no-voted")
            expect(page).not_to have_css("button.voted")
          end
        end

        within("#debate_#{debate2.id}_votes") do
          within(".in-favor") do
            expect(page).not_to have_css("button.voted")
            expect(page).not_to have_css("button.no-voted")
          end

          within(".against") do
            expect(page).not_to have_css("button.no-voted")
            expect(page).not_to have_css("button.voted")
          end
        end

        within("#debate_#{debate3.id}_votes") do
          within(".in-favor") do
            expect(page).to have_css("button.no-voted")
            expect(page).not_to have_css("button.voted")
          end

          within(".against") do
            expect(page).to have_css("button.voted")
            expect(page).not_to have_css("button.no-voted")
          end
        end
      end
    end

    describe "Single debate" do
      scenario "Show no votes" do
        visit debate_path(create(:debate))

        expect(page).to have_content "No votes"

        within(".in-favor") do
          expect(page).to have_content "0%"
          expect(page).not_to have_css("button.voted")
          expect(page).not_to have_css("button.no-voted")
        end

        within(".against") do
          expect(page).to have_content "0%"
          expect(page).not_to have_css("button.voted")
          expect(page).not_to have_css("button.no-voted")
        end
      end

      scenario "Update" do
        visit debate_path(create(:debate))

        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "100%"
          expect(page).to have_css("button.voted")
        end

        click_button "I disagree"

        within(".in-favor") do
          expect(page).to have_content "0%"
          expect(page).to have_css("button.no-voted")
        end

        within(".against") do
          expect(page).to have_content "100%"
          expect(page).to have_css("button.voted")
        end

        expect(page).to have_content "1 vote"
      end

      scenario "Trying to vote multiple times" do
        visit debate_path(create(:debate))

        click_button "I agree"
        expect(page).to have_content "1 vote"
        click_button "I agree"
        expect(page).not_to have_content "2 votes"

        within(".in-favor") do
          expect(page).to have_content "100%"
        end

        within(".against") do
          expect(page).to have_content "0%"
        end
      end

      scenario "Show" do
        debate = create(:debate)
        create(:vote, voter: verified, votable: debate, vote_flag: true)
        create(:vote, voter: unverified, votable: debate, vote_flag: false)

        visit debate_path(debate)

        expect(page).to have_content "No votes"

        within(".in-favor") do
          expect(page).to have_content "50%"
          expect(page).to have_css("button.voted")
        end

        within(".against") do
          expect(page).to have_content "50%"
          expect(page).to have_css("button.no-voted")
        end
      end

      scenario "Create from debate show" do
        visit debate_path(create(:debate))

        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "100%"
          expect(page).to have_css("button.voted")
        end

        within(".against") do
          expect(page).to have_content "0%"
          expect(page).to have_css("button.no-voted")
        end

        expect(page).to have_content "1 vote"
      end

      scenario "Create in index" do
        create(:debate)
        visit debates_path

        within("#debates") do
          click_button "I agree"

          within(".in-favor") do
            expect(page).to have_content "100%"
            expect(page).to have_css("button.voted")
          end

          within(".against") do
            expect(page).to have_content "0%"
            expect(page).to have_css("button.no-voted")
          end

          expect(page).to have_content "1 vote"
        end
        expect(page).to have_current_path(debates_path)
      end
    end
  end

  describe "Proposals" do
    before { login_as(verified) }

    describe "Single proposal" do
      let!(:proposal) { create(:proposal) }

      scenario "Show no votes" do
        visit proposal_path(proposal)
        expect(page).to have_content "No supports"
      end

      scenario "Trying to vote multiple times" do
        visit proposal_path(proposal)

        within(".supports") do
          click_button "Support"

          expect(page).to have_content "1 support"
          expect(page).not_to have_button "Support"
        end
      end

      scenario "Show" do
        create(:vote, voter: verified, votable: proposal, vote_flag: true)
        create(:vote, voter: unverified, votable: proposal, vote_flag: true)

        visit proposal_path(proposal)

        within(".supports") do
          expect(page).to have_content "2 supports"
        end
      end

      scenario "Create from proposal show" do
        visit proposal_path(proposal)

        within(".supports") do
          click_button "Support"

          expect(page).to have_content "1 support"
          expect(page).to have_content "You have already supported this proposal. Share it!"
        end
      end

      scenario "Create in listed proposal in index" do
        visit proposals_path

        within("#proposal_#{proposal.id}") do
          click_button "Support"

          expect(page).to have_content "1 support"
          expect(page).to have_content "You have already supported this proposal. Share it!"
        end
        expect(page).to have_current_path(proposals_path)
      end

      scenario "Create in featured proposal in index" do
        visit proposals_path

        within("#proposal_#{proposal.id}") do
          click_button "Support"

          expect(page).to have_content "You have already supported this proposal. Share it!"
        end
        expect(page).to have_current_path(proposals_path)
      end
    end
  end

  scenario "Not logged user trying to vote debates" do
    debate = create(:debate)

    visit debates_path
    within("#debate_#{debate.id}") do
      click_button "I agree"

      expect(page).to have_content "You must sign in or sign up to continue"
      expect(page).to have_button "I agree", disabled: true
      expect(page).to have_button "I disagree", disabled: true
    end
  end

  scenario "Not logged user trying to vote proposals" do
    proposal = create(:proposal)

    visit proposals_path
    within("#proposal_#{proposal.id}") do
      click_button "Support"

      expect(page).to have_content "You must sign in or sign up to continue"
      expect(page).not_to have_button "Support", disabled: :all
    end

    visit proposal_path(proposal)
    within("#proposal_#{proposal.id}") do
      click_button "Support"

      expect(page).to have_content "You must sign in or sign up to continue"
      expect(page).not_to have_button "Support", disabled: :all
    end
  end

  scenario "Not logged user trying to vote comments in debates" do
    debate = create(:debate)
    comment = create(:comment, commentable: debate)

    visit comment_path(comment)

    within("#comment_#{comment.id}") do
      click_button "I agree"
    end

    expect(page).to have_current_path new_user_session_path
  end

  scenario "Not logged user trying to vote comments in proposals" do
    proposal = create(:proposal)
    comment = create(:comment, commentable: proposal)

    visit comment_path(comment)

    within("#comment_#{comment.id}_reply") do
      click_button "I agree"
    end

    expect(page).to have_current_path new_user_session_path
  end

  scenario "Anonymous user trying to vote debates" do
    user = create(:user)
    debate = create(:debate)

    Setting["max_ratio_anon_votes_on_debates"] = 50
    debate.update!(cached_anonymous_votes_total: 520, cached_votes_total: 1000)

    login_as(user)

    visit debates_path
    within("#debate_#{debate.id}") do
      click_button "I agree"

      expect(page).to have_content "Too many anonymous votes to admit vote"
      expect(page).to have_button "I agree", disabled: true
    end

    visit debate_path(debate)
    within("#debate_#{debate.id}") do
      click_button "I agree"

      expect(page).to have_content "Too many anonymous votes to admit vote"
      expect(page).to have_button "I agree", disabled: true
    end
  end

  scenario "Anonymous user trying to vote proposals" do
    user = create(:user)
    proposal = create(:proposal)

    login_as(user)
    visit proposals_path

    within("#proposal_#{proposal.id}") do
      click_button "Support"

      expect(page).to have_content "Only verified users can vote on proposals"
      expect(page).not_to have_button "Support", disabled: :all
    end

    visit proposal_path(proposal)
    within("#proposal_#{proposal.id}") do
      click_button "Support"

      expect(page).to have_content "Only verified users can vote on proposals"
      expect(page).not_to have_button "Support", disabled: :all
    end
  end
end
