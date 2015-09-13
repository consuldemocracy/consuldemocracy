require 'rails_helper'

feature 'Votes' do

  background do
    @manuela = create(:user, verified_at: Time.now)
    @pablo = create(:user)

    login_as(@manuela)
  end

  feature 'Debates' do
    xscenario "Home shows user votes on featured debates" do
      pending "logged in user cannot see this page"

      debate1 = create(:debate)
      debate2 = create(:debate)
      debate3 = create(:debate)
      create(:vote, voter: @manuela, votable: debate1, vote_flag: true)
      create(:vote, voter: @manuela, votable: debate3, vote_flag: false)

      visit root_path

      within("#debate_#{debate1.id}_votes") do
        within(".in-favor") do
          expect(page).to have_css("a.voted")
          expect(page).to_not have_css("a.no-voted")
        end

        within(".against") do
          expect(page).to have_css("a.no-voted")
          expect(page).to_not have_css("a.voted")
        end
      end

      within("#debate_#{debate2.id}_votes") do
        within(".in-favor") do
          expect(page).to_not have_css("a.voted")
          expect(page).to_not have_css("a.no-voted")
        end

        within(".against") do
          expect(page).to_not have_css("a.no-voted")
          expect(page).to_not have_css("a.voted")
        end
      end

      within("#debate_#{debate3.id}_votes") do
        within(".in-favor") do
          expect(page).to have_css("a.no-voted")
          expect(page).to_not have_css("a.voted")
        end

        within(".against") do
          expect(page).to have_css("a.voted")
          expect(page).to_not have_css("a.no-voted")
        end
      end
    end

    scenario "Index shows user votes on debates" do
      debate1 = create(:debate)
      debate2 = create(:debate)
      debate3 = create(:debate)
      create(:vote, voter: @manuela, votable: debate1, vote_flag: true)
      create(:vote, voter: @manuela, votable: debate3, vote_flag: false)

      visit debates_path

      within("#debates") do
        within("#debate_#{debate1.id}_votes") do
          within(".in-favor") do
            expect(page).to have_css("a.voted")
            expect(page).to_not have_css("a.no-voted")
          end

          within(".against") do
            expect(page).to have_css("a.no-voted")
            expect(page).to_not have_css("a.voted")
          end
        end

        within("#debate_#{debate2.id}_votes") do
          within(".in-favor") do
            expect(page).to_not have_css("a.voted")
            expect(page).to_not have_css("a.no-voted")
          end

          within(".against") do
            expect(page).to_not have_css("a.no-voted")
            expect(page).to_not have_css("a.voted")
          end
        end

        within("#debate_#{debate3.id}_votes") do
          within(".in-favor") do
            expect(page).to have_css("a.no-voted")
            expect(page).to_not have_css("a.voted")
          end

          within(".against") do
            expect(page).to have_css("a.voted")
            expect(page).to_not have_css("a.no-voted")
          end
        end
      end
    end

    feature 'Single debate' do
      background do
        @debate = create(:debate)
      end

      scenario 'Show no votes' do
        visit debate_path(@debate)

        expect(page).to have_content "No votes"

        within('.in-favor') do
          expect(page).to have_content "0%"
          expect(page).to_not have_css("a.voted")
          expect(page).to_not have_css("a.no-voted")
        end

        within('.against') do
          expect(page).to have_content "0%"
          expect(page).to_not have_css("a.voted")
          expect(page).to_not have_css("a.no-voted")
        end
      end

      scenario 'Update', :js do
        visit debate_path(@debate)

        find('.in-favor a').click
        find('.against a').click

        within('.in-favor') do
          expect(page).to have_content "0%"
          expect(page).to have_css("a.no-voted")
        end

        within('.against') do
          expect(page).to have_content "100%"
          expect(page).to have_css("a.voted")
        end

        expect(page).to have_content "1 vote"
      end

      scenario 'Trying to vote multiple times', :js do
        visit debate_path(@debate)

        find('.in-favor a').click
        find('.in-favor a').click

        within('.in-favor') do
          expect(page).to have_content "100%"
        end

        within('.against') do
          expect(page).to have_content "0%"
        end

        expect(page).to have_content "1 vote"
      end

      scenario 'Show' do
        create(:vote, voter: @manuela, votable: @debate, vote_flag: true)
        create(:vote, voter: @pablo, votable: @debate, vote_flag: false)

        visit debate_path(@debate)

        expect(page).to have_content "2 votes"

        within('.in-favor') do
          expect(page).to have_content "50%"
          expect(page).to have_css("a.voted")
        end

        within('.against') do
          expect(page).to have_content "50%"
          expect(page).to have_css("a.no-voted")
        end
      end

      scenario 'Create from debate show', :js do
        visit debate_path(@debate)

        find('.in-favor a').click

        within('.in-favor') do
          expect(page).to have_content "100%"
          expect(page).to have_css("a.voted")
        end

        within('.against') do
          expect(page).to have_content "0%"
          expect(page).to have_css("a.no-voted")
        end

        expect(page).to have_content "1 vote"
      end

      xscenario 'Create in featured', :js do
        pending "logged in user cannot see this page"
        visit root_path

        find('.in-favor a').click

        within('.in-favor') do
          expect(page).to have_content "100%"
          expect(page).to have_css("a.voted")
        end

        within('.against') do
          expect(page).to have_content "0%"
          expect(page).to have_css("a.no-voted")
        end

        expect(page).to have_content "1 vote"
        expect(current_path).to eq(root_path)
      end

      scenario 'Create in index', :js do
        visit debates_path

        within("#debates") do

          find('.in-favor a').click

          within('.in-favor') do
            expect(page).to have_content "100%"
            expect(page).to have_css("a.voted")
          end

          within('.against') do
            expect(page).to have_content "0%"
            expect(page).to have_css("a.no-voted")
          end

          expect(page).to have_content "1 vote"
        end
        expect(current_path).to eq(debates_path)
      end
    end

    scenario 'Not logged user trying to vote', :js do
      debate = create(:debate)

      visit "/"
      click_link "Logout"

      within("#debate_#{debate.id}") do
        find("div.votes").hover
        expect_message_you_need_to_sign_in
      end

      visit debates_path
      within("#debate_#{debate.id}") do
        find("div.votes").hover
        expect_message_you_need_to_sign_in
      end

      visit debate_path(debate)
      within("#debate_#{debate.id}") do
        find("div.votes").hover
        expect_message_you_need_to_sign_in
      end
    end

    scenario 'Anonymous user trying to vote', :js do
      user = create(:user)
      debate = create(:debate)

      Setting.find_by(key: "max_ratio_anon_votes_on_debates").update(value: 50)
      debate.update(cached_anonymous_votes_total: 520, cached_votes_total: 1000)

      login_as(user)

      visit debates_path
      within("#debate_#{debate.id}") do
        find("div.votes").hover
        expect_message_to_many_anonymous_votes
      end

      visit debate_path(debate)
      within("#debate_#{debate.id}") do
        find("div.votes").hover
        expect_message_to_many_anonymous_votes
      end
    end
  end

  feature 'Comments' do
    background do
      @debate = create(:debate)
      @comment = create(:comment, commentable: @debate)
    end

    scenario 'Show' do
      create(:vote, voter: @manuela, votable: @comment, vote_flag: true)
      create(:vote, voter: @pablo, votable: @comment, vote_flag: false)

      visit debate_path(@debate)

      within("#comment_#{@comment.id}_votes") do
        within(".in_favor") do
          expect(page).to have_content "1"
        end

        within(".against") do
          expect(page).to have_content "1"
        end

        expect(page).to have_content "2 votes"
      end
    end

    scenario 'Create', :js do
      visit debate_path(@debate)

      within("#comment_#{@comment.id}_votes") do
        find(".in_favor a").click

        within(".in_favor") do
          expect(page).to have_content "1"
        end

        within(".against") do
          expect(page).to have_content "0"
        end

        expect(page).to have_content "1 vote"
      end
    end

    scenario 'Update', :js do
      visit debate_path(@debate)

      within("#comment_#{@comment.id}_votes") do
        find('.in_favor a').click
        find('.against a').click

        within('.in_favor') do
          expect(page).to have_content "0"
        end

        within('.against') do
          expect(page).to have_content "1"
        end

        expect(page).to have_content "1 vote"
      end
    end

    scenario 'Trying to vote multiple times', :js do
      visit debate_path(@debate)

      within("#comment_#{@comment.id}_votes") do
        find('.in_favor a').click
        find('.in_favor a').click

        within('.in_favor') do
          expect(page).to have_content "1"
        end

        within('.against') do
          expect(page).to have_content "0"
        end

        expect(page).to have_content "1 vote"
      end
    end
  end

  feature 'Proposals' do
    xscenario "Home shows user votes on featured proposals" do
      pending "logged in user cannot see this page"
      proposal1 = create(:proposal)
      proposal2 = create(:proposal)
      proposal3 = create(:proposal)
      create(:vote, voter: @manuela, votable: proposal1, vote_flag: true)
      create(:vote, voter: @manuela, votable: proposal3, vote_flag: false)

      visit root_path

      within("#featured-proposals") do
        within("#proposal_#{proposal1.id}_votes") do
          within(".supports") do
            expect(page).to have_css("a.voted")
            expect(page).to_not have_css("a.no-voted")
          end
        end

        within("#proposal_#{proposal2.id}_votes") do
          within(".supports") do
            expect(page).to_not have_css("a.voted")
            expect(page).to_not have_css("a.no-voted")
          end
        end

        within("#proposal_#{proposal3.id}_votes") do
          within(".supports") do
            expect(page).to have_css("a.no-voted")
            expect(page).to_not have_css("a.voted")
          end
        end
      end
    end

    scenario "Index shows user votes on proposals" do
      proposal1 = create(:proposal)
      proposal2 = create(:proposal)
      proposal3 = create(:proposal)
      create(:vote, voter: @manuela, votable: proposal1, vote_flag: true)
      create(:vote, voter: @manuela, votable: proposal3, vote_flag: false)

      visit proposals_path

      within("#proposals") do
        within("#proposal_#{proposal1.id}_votes") do
          expect(page).to have_css("a.voted")
          expect(page).to_not have_css("a.no-voted")
        end

        within("#proposal_#{proposal2.id}_votes") do
          expect(page).to_not have_css("a.voted")
          expect(page).to_not have_css("a.no-voted")
        end

        within("#proposal_#{proposal3.id}_votes") do
          expect(page).to have_css("a.no-voted")
          expect(page).to_not have_css("a.voted")
        end
      end
    end

    feature 'Single proposal' do
      background do
        @proposal = create(:proposal)
      end

      scenario 'Show no votes' do
        visit proposal_path(@proposal)

        expect(page).to have_content "No supports"

        within('.supports') do
          expect(page).to_not have_css("a.voted")
          expect(page).to_not have_css("a.no-voted")
        end
      end

      scenario 'Update', :js do
        visit proposal_path(@proposal)

        within('.supports') do
          find('.in-favor a').click
          expect(page).to have_content "1 support"
          expect(page).to have_css("a.voted")

          find('.in-favor a').click
          expect(page).to have_content "No supports"
          expect(page).to_not have_css("a.no-voted")
        end
      end

      scenario 'Trying to vote multiple times', :js do
        visit proposal_path(@proposal)

        within('.supports') do
          find('.in-favor a').click
          find('.in-favor a').click

          expect(page).to have_content "1 support"
        end
      end

      scenario 'Show' do
        create(:vote, voter: @manuela, votable: @proposal, vote_flag: true)
        create(:vote, voter: @pablo, votable: @proposal, vote_flag: true)

        visit proposal_path(@proposal)

        within('.supports') do
          expect(page).to have_content "2 supports / 53.726"
        end
      end

      scenario 'Create from proposal show', :js do
        visit proposal_path(@proposal)

        within('.supports') do
          find('.in-favor a').click

          expect(page).to have_content "1 support"
          expect(page).to have_css("a.voted")
        end
      end

      xscenario 'Create in featured', :js do
        pending "logged in user cannot see this page"
        visit root_path

        within("#featured-proposals") do
          find('.in-favor a').click

          expect(page).to have_content "1 support"
          expect(page).to have_css("a.voted")
        end
        expect(URI.parse(current_url).path).to eq(root_path)
      end

      scenario 'Create in index', :js do
        visit proposals_path

        within("#proposals") do
          find('.in-favor a').click

          expect(page).to have_content "1 support"
          expect(page).to have_css("a.voted")
        end
        expect(URI.parse(current_url).path).to eq(proposals_path)
      end
    end
  end

  scenario 'Not logged user trying to vote', :js do
    proposal = create(:proposal)

    visit "/"
    click_link "Logout"

    within("#proposal_#{proposal.id}") do
      find("div.supports").hover
      expect_message_you_need_to_sign_in
    end

    visit proposals_path
    within("#proposal_#{proposal.id}") do
      find("div.supports").hover
      expect_message_you_need_to_sign_in
    end

    visit proposal_path(proposal)
    within("#proposal_#{proposal.id}") do
      find("div.supports").hover
      expect_message_you_need_to_sign_in
    end
  end

  scenario "Anonymous user trying to vote", :js do
    user = create(:user)
    proposal = create(:proposal)

    login_as(user)
    visit proposals_path

    within("#proposal_#{proposal.id}") do
      find("div.supports").hover
      expect_message_only_verified_can_vote
    end

    visit proposal_path(proposal)
    within("#proposal_#{proposal.id}") do
      find("div.supports").hover
      expect_message_only_verified_can_vote
    end
  end
end
