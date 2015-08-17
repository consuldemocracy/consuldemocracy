require 'rails_helper'

feature 'Admin comments' do

  scenario 'Restore', :js do
    citizen = create(:user)
    admin = create(:administrator)

    debate = create(:debate)
    comment = create(:comment, :hidden, commentable: debate, body: 'Not really SPAM')

    login_as(admin.user)
    visit admin_comments_path

    within("#comment_#{comment.id}") do
      first(:link, "Restore").click
    end

    expect(page).to have_content 'The comment has been restored'

    login_as(citizen)
    visit debate_path(debate)

    expect(page).to have_css('.comment', count: 1)
    expect(page).to have_content('Not really SPAM')
  end

end