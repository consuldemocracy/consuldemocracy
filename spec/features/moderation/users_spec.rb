require 'rails_helper'

feature 'Moderate users' do

  scenario 'Hide' do
    citizen = create(:user)
    moderator = create(:moderator)

    debate1 = create(:debate, author: citizen)
    debate2 = create(:debate, author: citizen)
    debate3 = create(:debate)
    comment3 = create(:comment, user: citizen, commentable: debate3, body: 'SPAMMER')

    login_as(moderator.user)
    visit debates_path

    expect(page).to have_content(debate1.title)
    expect(page).to have_content(debate2.title)
    expect(page).to have_content(debate3.title)

    visit debate_path(debate3)

    expect(page).to have_content(comment3.body)

    visit debate_path(debate1)

    within("#debate_#{debate1.id}") do
      click_link 'Ban author'
    end

    expect(current_path).to eq(debates_path)
    expect(page).to_not have_content(debate1.title)
    expect(page).to_not have_content(debate2.title)
    expect(page).to have_content(debate3.title)

    visit debate_path(debate3)

    expect(page).to_not have_content(comment3.body)

    click_link("Logout")

    click_link 'Log in'
    fill_in 'user_email',    with: citizen.email
    fill_in 'user_password', with: citizen.password
    click_button 'Log in'

    expect(page).to have_content 'Invalid email or password'
    expect(current_path).to eq(new_user_session_path)
  end

end