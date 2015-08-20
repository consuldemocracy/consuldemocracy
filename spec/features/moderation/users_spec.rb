require 'rails_helper'

feature 'Moderate users' do

  scenario 'Hide' do
    citizen = create(:user)
    moderator = create(:moderator)

    debate1 = create(:debate, author: citizen)
    comment1 = create(:comment, user: citizen, commentable: debate1, body: 'SPAM')
    debate2 = create(:debate, author: citizen)
    comment2 = create(:comment, user: citizen, commentable: debate2, body: 'Hello')

    login_as(moderator.user)

    visit debates_path

    expect(page).to have_content(debate1.title)
    expect(page).to have_content(debate2.title)

    visit debate_path(debate1)

    within("#debate_#{debate1.id}") do
      click_link 'Ban author'
    end

    expect(current_path).to eq(debates_path)
    expect(page).to_not have_content(debate1.title)
    expect(page).to_not have_content(debate2.title)

    click_link("Logout")

    click_link 'Log in'
    fill_in 'user_email',    with: citizen.email
    fill_in 'user_password', with: citizen.password
    click_button 'Log in'

    expect(page).to have_content 'Invalid email or password'
    expect(current_path).to eq(new_user_session_path)
  end

end