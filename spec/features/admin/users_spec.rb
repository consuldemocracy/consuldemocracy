require 'rails_helper'

feature 'Admin users' do

  scenario 'Restore hidden user' do
    citizen = create(:user)
    admin = create(:administrator)
    create(:moderator, user: admin.user)

    debate_previously_hidden = create(:debate, :hidden, author: citizen)
    debate = create(:debate, author: citizen)
    comment_previously_hidden = create(:comment, :hidden, user: citizen, commentable: debate, body: "You have the manners of a beggar")
    comment = create(:comment, user: citizen, commentable: debate, body: 'Not Spam')

    login_as(admin.user)
    visit debate_path(debate)

    within("#debate_#{debate.id}") do
      click_link 'Ban author'
    end

    visit debates_path
    expect(page).to_not have_content(debate.title)
    expect(page).to_not have_content(debate_previously_hidden)

    click_link "Administration"
    click_link "Hidden users"
    click_link "Restore user"

    visit debates_path
    expect(page).to have_content(debate.title)
    expect(page).to_not have_content(debate_previously_hidden)

    visit debate_path(debate)
    expect(page).to have_content(comment.body)
    expect(page).to_not have_content(comment_previously_hidden.body)
  end

  scenario 'Show user activity' do
    citizen = create(:user)
    admin = create(:administrator)
    create(:moderator, user: admin.user)

    debate1 = create(:debate, :hidden, author: citizen)
    debate2 = create(:debate, author: citizen)
    comment1 = create(:comment, :hidden, user: citizen, commentable: debate2, body: "You have the manners of a beggar")
    comment2 = create(:comment, user: citizen, commentable: debate2, body: 'Not Spam')

    login_as(admin.user)
    visit debate_path(debate2)

    within("#debate_#{debate2.id}") do
      click_link 'Ban author'
    end

    click_link "Administration"
    click_link "Hidden users"
    click_link citizen.name

    expect(page).to have_content(debate1.title)
    expect(page).to have_content(debate2.title)
    expect(page).to have_content(comment1.body)
    expect(page).to have_content(comment2.body)
  end

end