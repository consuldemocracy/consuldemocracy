require 'rails_helper'

feature "Welcome screen" do

  scenario 'a regular users sees it the first time he logs in' do
    user = create(:user)

    login_through_form_as(user)

    expect(current_path).to eq(welcome_path)
  end

  scenario 'a regular user does not see it when coing to /email' do

    plain, encrypted = Devise.token_generator.generate(User, :email_verification_token)

    user = create(:user, email_verification_token: plain)

    visit email_path(email_verification_token: encrypted)

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password

    click_button 'Enter'

    expect(page).to have_content("You are a verified user")

    expect(current_path).to eq(account_path)
  end
end
