require 'rails_helper'

feature 'Votes' do

  feature 'Debates' do

    background do
      @manuela = create(:user)
      @pablo = create(:user)
      @debate = create(:debate)

      login_as(@manuela)
      visit debate_path(@debate)
    end

    scenario 'Show' do
      vote = create(:vote, voter: @manuela, votable: @debate, vote_flag: true)
      vote = create(:vote, voter: @pablo, votable: @debate, vote_flag: false)

      visit debate_path(@debate)

      expect(page).to have_content "2 votes"

      within('#in_favor') do
        expect(page).to have_content "50%"
      end

      within('#against')  do
        expect(page).to have_content "50%"
      end
    end

    scenario 'Create from debate show', :js do
      find('#in_favor a').click

      within('#in_favor') do
        expect(page).to have_content "100%"
      end

      within('#against')  do
        expect(page).to have_content "0%"
      end

      expect(page).to have_content "1 vote"
    end

    scenario 'Create from debate featured', :js do
      visit debates_path

      within("#featured-debates") do
        find('#in_favor a').click

        within('#in_favor') do
          expect(page).to have_content "100%"
        end

        within('#against')  do
          expect(page).to have_content "0%"
        end

        expect(page).to have_content "1 vote"
      end
      expect(URI.parse(current_url).path).to eq(debates_path)
    end

    scenario 'Create from debate index', :js do
      3.times { create(:debate) }
      visit debates_path

      within("#debates") do
        expect(page).to have_css(".debate", count: 1)

        find('#in_favor a').click

        within('#in_favor') do
          expect(page).to have_content "100%"
        end

        within('#against')  do
          expect(page).to have_content "0%"
        end

        expect(page).to have_content "1 vote"
      end
      expect(URI.parse(current_url).path).to eq(debates_path)
    end

    scenario 'Update', :js do
      find('#in_favor a').click
      find('#against a').click

      within('#in_favor') do
        expect(page).to have_content "0%"
      end

      within('#against')  do
        expect(page).to have_content "100%"
      end

      expect(page).to have_content "1 vote"
    end

    scenario 'Trying to vote multiple times', :js do
      find('#in_favor a').click
      find('#in_favor a').click

      within('#in_favor') do
        expect(page).to have_content "100%"
      end

      within('#against')  do
        expect(page).to have_content "0%"
      end

      expect(page).to have_content "1 vote"
    end

  end


  feature 'Comments' do

    background do
      @manuela = create(:user)
      @pablo = create(:user)
      @debate = create(:debate)
      @comment = create(:comment, commentable: @debate)

      login_as(@manuela)
      visit debate_path(@debate)
    end

    scenario 'Show' do
      vote = create(:vote, voter: @manuela, votable: @comment, vote_flag: true)
      vote = create(:vote, voter: @pablo, votable: @comment, vote_flag: false)

      visit debate_path(@debate)

      within("#comment_#{@comment.id}_votes") do
        within(".in_favor")  do
          expect(page).to have_content "1"
        end

        within(".against")  do
          expect(page).to have_content "1"
        end
      end
    end

    scenario 'Create', :js do
      within("#comment_#{@comment.id}_votes") do
        find(".in_favor a").click

        within(".in_favor") do
          expect(page).to have_content "1"
        end

        within(".against")  do
          expect(page).to have_content "0"
        end
      end
    end

    scenario 'Update', :js do
      within("#comment_#{@comment.id}_votes") do
        find('.in_favor a').click
        find('.against a').click

        within('.in_favor') do
          expect(page).to have_content "0"
        end

        within('.against')  do
          expect(page).to have_content "1"
        end
      end
    end

    scenario 'Trying to vote multiple times', :js do
      within("#comment_#{@comment.id}_votes") do
        find('.in_favor a').click
        find('.in_favor a').click

        within('.in_favor') do
          expect(page).to have_content "1"
        end

        within('.against')  do
          expect(page).to have_content "0"
        end
      end
    end

  end
end