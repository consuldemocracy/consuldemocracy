require 'rails_helper'

feature 'Users' do

  scenario 'Sign up' do
    visit '/'
    click_link 'Login'
    click_link 'Sign up'

    fill_in 'user_first_name',            with: 'Manuela'
    fill_in 'user_last_name',             with: 'Carmena'
    fill_in 'user_email',                 with: 'manuela@madrid.es'
    fill_in 'user_password',              with: 'judgementday'
    fill_in 'user_password_confirmation', with: 'judgementday'

    click_button 'Sign up'

    expect(page).to have_content '¡Bienvenido! Has sido identificado.'
  end
  
  scenario 'Sign in' do
    user = create(:user, email: 'manuela@madrid.es', password: 'judgementday')

    visit '/'
    click_link 'Login'
    fill_in 'user_email',    with: 'manuela@madrid.es'
    fill_in 'user_password', with: 'judgementday'
    click_button 'Log in'
    
    expect(page).to have_content 'Has iniciado sesión correctamente.'
  end

  scenario 'Sign out' do
    user = create(:user)
    login_as(user)
    
    visit "/"
    click_link 'Logout'

    expect(page).to have_content 'Has cerrado la sesión correctamente.'
  end

end
