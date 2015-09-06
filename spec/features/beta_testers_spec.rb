require 'rails_helper'

feature 'Beta testers' do

  background do
    allow_any_instance_of(ApplicationController).
    to receive(:beta_site?).and_return(true)

    allow_any_instance_of(ApplicationController).
    to receive(:beta_testers).and_return(['isabel@example.com'])
  end

  scenario 'Beta testers should have access' do
    visit root_path
    sign_up('isabel@example.com', 'secretpassword')
    confirm_email

    fill_in 'user_email',    with: 'isabel@example.com'
    fill_in 'user_password', with: 'secretpassword'
    click_button 'Log in'

    expect(page).to have_content "Signed in successfully."
  end

  scenario 'Non beta testers should not have access' do
    visit root_path
    sign_up('other@example.com', 'secretpassword')
    confirm_email

    fill_in 'user_email',    with: 'other@example.com'
    fill_in 'user_password', with: 'secretpassword'
    click_button 'Log in'

    expect(page).to have_content "Sorry only Beta Testers are allowed access at the moment"
  end

  scenario "Trying to access site without being logged in" do
    visit debates_path

    expect(page).to have_content "Sorry only Beta Testers are allowed access at the moment"
    expect(current_path).to eq(new_user_session_path)
  end

end