require 'rails_helper'

feature 'Moderate comments' do

  scenario 'Hide', :js do
    citizen = create(:user)
    moderator = create(:moderator)

    comment = create(:comment)

    login_as(moderator.user)
    visit debate_path(comment.commentable)

    within("#comment_#{comment.id}") do
      click_link 'Hide'
      expect(page).to have_css('.comment .faded')
    end

    login_as(citizen)
    visit debate_path(comment.commentable)

    expect(page).to have_css('.comment', count: 1)
    expect(page).to_not have_content('This comment has been deleted')
    expect(page).to_not have_content('SPAM')
  end

  scenario 'Can not hide own comment' do
    moderator = create(:moderator)
    comment = create(:comment, user: moderator.user)

    login_as(moderator.user)
    visit debate_path(comment.commentable)

    within("#comment_#{comment.id}") do
      expect(page).to_not have_link('Hide')
      expect(page).to_not have_link('Block author')
    end
  end

  feature '/moderation/ screen' do

    background do
      moderator = create(:moderator)
      login_as(moderator.user)
    end

    feature 'moderate in bulk' do
      feature "When a comment has been selected for moderation" do
        background do
          @comment = create(:comment)
          visit moderation_comments_path
          within('.menu.simple') do
            click_link "All"
          end

          within("#comment_#{@comment.id}") do
            check "comment_#{@comment.id}_check"
          end

          expect(page).to_not have_css("comment_#{@comment.id}")
        end

        scenario 'Hide the comment' do
          click_on "Hide comments"
          expect(page).to_not have_css("comment_#{@comment.id}")
          expect(@comment.reload).to be_hidden
          expect(@comment.user).to_not be_hidden
        end

        scenario 'Block the user' do
          click_on "Block authors"
          expect(page).to_not have_css("comment_#{@comment.id}")
          expect(@comment.reload).to be_hidden
          expect(@comment.user).to be_hidden
        end

        scenario 'Ignore the comment' do
          click_on "Mark as viewed"
          expect(page).to_not have_css("comment_#{@comment.id}")
          expect(@comment.reload).to be_ignored_flag
          expect(@comment.reload).to_not be_hidden
          expect(@comment.user).to_not be_hidden
        end
      end

      scenario "select all/none", :js do
        Capybara.current_driver = :poltergeist_no_js_errors

        create_list(:comment, 2)

        visit moderation_comments_path

        within('.js-check') { click_on 'All' }

        all('input[type=checkbox]').each do |checkbox|
          expect(checkbox).to be_checked
        end

        within('.js-check') { click_on 'None' }

        all('input[type=checkbox]').each do |checkbox|
          expect(checkbox).to_not be_checked
        end
      end

      scenario "remembering page, filter and order" do
        create_list(:comment, 52)

        visit moderation_comments_path(filter: 'all', page: '2', order: 'newest')

        click_on "Mark as viewed"

        expect(page).to have_selector('.js-order-selector[data-order="newest"]')

        expect(current_url).to include('filter=all')
        expect(current_url).to include('page=2')
        expect(current_url).to include('order=newest')
      end
    end

    scenario "Current filter is properly highlighted" do
      visit moderation_comments_path
      expect(page).to_not have_link('Pending')
      expect(page).to have_link('All')
      expect(page).to have_link('Marked as viewed')

      visit moderation_comments_path(filter: 'all')
      within('.menu.simple') do
        expect(page).to_not have_link('All')
        expect(page).to have_link('Pending')
        expect(page).to have_link('Marked as viewed')
      end

      visit moderation_comments_path(filter: 'pending_flag_review')
      within('.menu.simple') do
        expect(page).to have_link('All')
        expect(page).to_not have_link('Pending')
        expect(page).to have_link('Marked as viewed')
      end

      visit moderation_comments_path(filter: 'with_ignored_flag')
      within('.menu.simple') do
        expect(page).to have_link('All')
        expect(page).to have_link('Pending')
        expect(page).to_not have_link('Marked as viewed')
      end
    end

    scenario "Filtering comments" do
      create(:comment, body: "Regular comment")
      create(:comment, :flagged, body: "Pending comment")
      create(:comment, :hidden, body: "Hidden comment")
      create(:comment, :flagged, :with_ignored_flag, body: "Ignored comment")

      visit moderation_comments_path(filter: 'all')
      expect(page).to have_content('Regular comment')
      expect(page).to have_content('Pending comment')
      expect(page).to_not have_content('Hidden comment')
      expect(page).to have_content('Ignored comment')

      visit moderation_comments_path(filter: 'pending_flag_review')
      expect(page).to_not have_content('Regular comment')
      expect(page).to have_content('Pending comment')
      expect(page).to_not have_content('Hidden comment')
      expect(page).to_not have_content('Ignored comment')

      visit moderation_comments_path(filter: 'with_ignored_flag')
      expect(page).to_not have_content('Regular comment')
      expect(page).to_not have_content('Pending comment')
      expect(page).to_not have_content('Hidden comment')
      expect(page).to have_content('Ignored comment')
    end

    scenario "sorting comments" do
      create(:comment, body: "Flagged comment", created_at: Time.current - 1.day, flags_count: 5)
      create(:comment, body: "Flagged newer comment", created_at: Time.current - 12.hours, flags_count: 3)
      create(:comment, body: "Newer comment", created_at: Time.current)

      visit moderation_comments_path(order: 'newest')

      expect("Flagged newer comment").to appear_before("Flagged comment")

      visit moderation_comments_path(order: 'flags')

      expect("Flagged comment").to appear_before("Flagged newer comment")

      visit moderation_comments_path(filter: 'all', order: 'newest')

      expect("Newer comment").to appear_before("Flagged newer comment")
      expect("Flagged newer comment").to appear_before("Flagged comment")

      visit moderation_comments_path(filter: 'all', order: 'flags')

      expect("Flagged comment").to appear_before("Flagged newer comment")
      expect("Flagged newer comment").to appear_before("Newer comment")
    end
  end
end
