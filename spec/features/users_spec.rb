require 'rails_helper'

feature 'Users' do

  scenario 'Sign up' do
    visit '/'
    click_link 'Registrarse'

    fill_in 'user_first_name',            with: 'Manuela'
    fill_in 'user_last_name',             with: 'Carmena'
    fill_in 'user_email',                 with: 'manuela@madrid.es'
    fill_in 'user_password',              with: 'judgementday'
    fill_in 'user_password_confirmation', with: 'judgementday'

    click_button 'Registrarse'

    expect(page).to have_content 'Welcome! You have signed up successfully.'
  end

  scenario 'Sign in' do
    user = create(:user, email: 'manuela@madrid.es', password: 'judgementday')

    visit '/'
    click_link 'Entrar'
    fill_in 'user_email',    with: 'manuela@madrid.es'
    fill_in 'user_password', with: 'judgementday'
    click_button 'Entrar'

    expect(page).to have_content 'Signed in successfully.'
  end

  scenario 'Sign out' do
    user = create(:user)
    login_as(user)

    visit "/"
    click_link 'Salir'

    expect(page).to have_content 'Signed out successfully.'
  end

end
