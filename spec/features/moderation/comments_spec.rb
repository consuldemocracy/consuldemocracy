require 'rails_helper'

feature 'Moderate Comments' do

  feature 'Hiding Comments' do

    scenario 'Hide without children hides the comment completely', :js do
      citizen = create(:user)
      moderator = create(:moderator)

      debate = create(:debate)
      comment = create(:comment, commentable: debate, body: 'SPAM')

      login_as(moderator.user)
      visit debate_path(debate)

      within("#comment_#{comment.id}") do
        click_link 'Hide'
        expect(page).to have_css('.comment .faded')
      end

      login_as(citizen)
      visit debate_path(debate)

      expect(page).to have_css('.comment', count: 1)
      expect(page).to_not have_content('This comment has been deleted')
      expect(page).to_not have_content('SPAM')
    end

    scenario 'Children visible', :js do
      citizen = create(:user)
      moderator = create(:moderator)

      debate = create(:debate)
      comment = create(:comment, commentable: debate, body: 'SPAM')
      create(:comment, commentable: debate, body: 'Acceptable reply', parent_id: comment.id)

      login_as(moderator.user)
      visit debate_path(debate)

      within("#comment_#{comment.id}") do
        first(:link, "Hide").click
        expect(page).to have_css('.comment .faded')
      end

      login_as(citizen)
      visit debate_path(debate)

      expect(page).to have_css('.comment', count: 2)
      expect(page).to have_content('This comment has been deleted')
      expect(page).to_not have_content('SPAM')

      expect(page).to have_content('Acceptable reply')
    end
  end

  scenario 'Moderator actions in the comment' do
    citizen = create(:user)
    moderator = create(:moderator)

    debate = create(:debate)
    comment = create(:comment, commentable: debate)

    login_as(moderator.user)
    visit debate_path(debate)

    within "#comment_#{comment.id}" do
      expect(page).to have_link("Hide")
      expect(page).to have_link("Ban author")
    end

    login_as(citizen)
    visit debate_path(debate)

    within "#comment_#{comment.id}" do
      expect(page).to_not have_link("Hide")
      expect(page).to_not have_link("Ban author")
    end
  end

  scenario 'Moderator actions do not appear in own comments' do
    moderator = create(:moderator)

    debate = create(:debate)
    comment = create(:comment, commentable: debate, user: moderator.user)

    login_as(moderator.user)
    visit debate_path(debate)

    within "#comment_#{comment.id}" do
      expect(page).to_not have_link("Hide")
      expect(page).to_not have_link("Ban author")
    end
  end

  feature '/moderation/ menu' do

    background do
      moderator = create(:moderator)
      login_as(moderator.user)
    end

    scenario "Current filter is properly highlighted" do
      visit moderation_comments_path
      expect(page).to_not have_link('Pending')
      expect(page).to have_link('All')
      expect(page).to have_link('Ignored')

      visit moderation_comments_path(filter: 'all')
      expect(page).to_not have_link('All')
      expect(page).to have_link('Pending')
      expect(page).to have_link('Ignored')

      visit moderation_comments_path(filter: 'pending_flag_review')
      expect(page).to have_link('All')
      expect(page).to_not have_link('Pending')
      expect(page).to have_link('Ignored')

      visit moderation_comments_path(filter: 'with_ignored_flag')
      expect(page).to have_link('All')
      expect(page).to have_link('Pending')
      expect(page).to_not have_link('Ignored')
    end

    scenario "Filtering comments" do
      create(:comment, :flagged, body: "Pending comment")
      create(:comment, :flagged, :hidden, body: "Hidden comment")
      create(:comment, :flagged, :with_ignored_flag, body: "Ignored comment")

      visit moderation_comments_path(filter: 'all')
      expect(page).to have_content('Pending comment')
      expect(page).to_not have_content('Hidden comment')
      expect(page).to have_content('Ignored comment')

      visit moderation_comments_path(filter: 'pending_flag_review')
      expect(page).to have_content('Pending comment')
      expect(page).to_not have_content('Hidden comment')
      expect(page).to_not have_content('Ignored comment')

      visit moderation_comments_path(filter: 'with_ignored_flag')
      expect(page).to_not have_content('Pending comment')
      expect(page).to_not have_content('Hidden comment')
      expect(page).to have_content('Ignored comment')
    end

    scenario "Reviewing links remember the pagination setting and the filter" do
      per_page = Kaminari.config.default_per_page
      (per_page + 2).times { create(:comment, :flagged) }

      visit moderation_comments_path(filter: 'pending_flag_review', page: 2)

      click_link('Ignore', match: :first, exact: true)

      expect(current_url).to include('filter=pending_flag_review')
      expect(current_url).to include('page=2')
    end

    feature 'A flagged comment exists' do

      background do
        debate = create(:debate, title: 'Democracy')
        @comment = create(:comment, :flagged, commentable: debate, body: 'spammy spam')
        visit moderation_comments_path
      end

      scenario 'It is displayed with the correct attributes' do
        within("#comment_#{@comment.id}") do
          expect(page).to have_link('Democracy')
          expect(page).to have_content('spammy spam')
          expect(page).to have_content('1')
          expect(page).to have_link('Hide')
          expect(page).to have_link('Ignore')
        end
      end

      scenario 'Hiding the comment' do
        within("#comment_#{@comment.id}") do
          click_link('Hide')
        end

        expect(current_path).to eq(moderation_comments_path)
        expect(page).to_not have_selector("#comment_#{@comment.id}")

        expect(@comment.reload).to be_hidden
      end

      scenario 'Marking the comment as ignored' do
        within("#comment_#{@comment.id}") do
          click_link('Ignore')
        end

        expect(current_path).to eq(moderation_comments_path)

        click_link('Ignored')

        within("#comment_#{@comment.id}") do
          expect(page).to have_content('Ignored')
        end

        expect(@comment.reload).to be_ignored_flag
      end
    end
  end
end
