require 'rails_helper'

feature 'Moderate Comments' do

  scenario 'Hide', :js do
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
    expect(page).to have_content('This comment has been deleted')
    expect(page).to_not have_content('SPAM')
  end

  scenario 'Children visible', :js do
    citizen = create(:user)
    moderator = create(:moderator)

    debate = create(:debate)
    comment = create(:comment, commentable: debate, body: 'SPAM')
    reply = create(:comment, commentable: debate, body: 'Acceptable reply', parent_id: comment.id)

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

  scenario 'Moderator actions' do
    citizen = create(:user)
    moderator = create(:moderator)

    debate = create(:debate)
    comment = create(:comment, commentable: debate)

    login_as(moderator.user)
    visit debate_path(debate)

    expect(page).to have_css("#moderator-comment-actions")

    login_as(citizen)
    visit debate_path(debate)

    expect(page).to_not have_css("#moderator-comment-actions")
  end

end