require 'rails_helper'

feature 'Votes' do

  background do
    @manuela = create(:user, verified_at: Time.now)
    @pablo = create(:user)

    login_as(@manuela)
  end

  feature 'Debates' do
    scenario "Home shows user votes on featured debates" do
      debate1 = create(:debate)
      debate2 = create(:debate)
      debate3 = create(:debate)
      create(:vote, voter: @manuela, votable: debate1, vote_flag: true)
      create(:vote, voter: @manuela, votable: debate3, vote_flag: false)

      visit root_path

      within("#featured-debates") do
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

      scenario 'Create in featured', :js do
        visit root_path

        within("#featured-debates") do
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
        expect(URI.parse(current_url).path).to eq(root_path)
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
        expect(URI.parse(current_url).path).to eq(debates_path)
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
end
