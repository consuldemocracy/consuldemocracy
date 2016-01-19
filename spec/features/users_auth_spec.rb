require 'rails_helper'

feature 'Users' do

  context 'Regular authentication' do
    scenario 'Sign up' do
      visit '/'
      click_link 'Register'

      fill_in 'user_username',              with: 'Manuela Carmena'
      fill_in 'user_email',                 with: 'manuela@madrid.es'
      fill_in 'user_password',              with: 'judgementday'
      fill_in 'user_password_confirmation', with: 'judgementday'
      fill_in 'user_captcha',               with: correct_captcha_text
      check 'user_terms_of_service'

      click_button 'Register'

      expect(page).to have_content "You have been sent a message containing a verification link. Please click on this link to activate your account."

      confirm_email

      expect(page).to have_content "Your account has been confirmed."
    end

    scenario 'Errors on sign up' do
      visit '/'
      click_link 'Register'
      click_button 'Register'

      expect(page).to have_content error_message
    end

    scenario 'Sign in' do
      create(:user, email: 'manuela@madrid.es', password: 'judgementday')

      visit '/'
      click_link 'Sign in'
      fill_in 'user_email',    with: 'manuela@madrid.es'
      fill_in 'user_password', with: 'judgementday'
      click_button 'Enter'

      expect(page).to have_content 'You have been signed in successfully.'
    end
  end

  context 'OAuth authentication' do
    context 'Twitter' do
      background do
        #request.env["devise.mapping"] = Devise.mappings[:user]
      end

      scenario 'Sign up, when email was provided by OAuth provider' do
        omniauth_twitter_hash = { 'provider' => 'twitter',
                                  'uid' => '12345',
                                  'info' => {
                                    'name' => 'manuela',
                                    'email' => 'manuelacarmena@example.com',
                                    'nickname' => 'ManuelaRocks',
                                    'verified' => '1'
                                  },
                                  'extra' => { 'raw_info' =>
                                    { 'location' => 'Madrid',
                                      'name' => 'Manuela de las Carmenas'
                                    }
                                  }
                                }

        OmniAuth.config.add_mock(:twitter, omniauth_twitter_hash)

        visit '/'
        click_link 'Register'

        click_link 'Sign up with Twitter'

        expect_to_be_signed_in

        click_link 'My account'
        expect(page).to have_field('account_username', with: 'ManuelaRocks')

        visit edit_user_registration_path
        expect(page).to have_field('user_email', with: 'manuelacarmena@example.com')
      end

      scenario 'Sign up, when neither email nor nickname were provided by OAuth provider' do
        omniauth_twitter_hash = { 'provider' => 'twitter',
                                  'uid' => '12345',
                                  'info' => {
                                    'name' => 'manuela'
                                  },
                                  'extra' => { 'raw_info' =>
                                    { 'location' => 'Madrid',
                                      'name' => 'Manuela de las Carmenas'
                                    }
                                  }
                                }

        OmniAuth.config.add_mock(:twitter, omniauth_twitter_hash)

        visit '/'
        click_link 'Register'
        click_link 'Sign up with Twitter'

        expect(current_path).to eq(finish_signup_path)
        fill_in 'user_email', with: 'manueladelascarmenas@example.com'
        click_button 'Register'

        expect(page).to have_content "You must confirm your account to continue"

        confirm_email
        expect(page).to have_content "Your account has been confirmed"

        visit '/'
        click_link 'Sign in'
        click_link 'Sign in with Twitter'
        expect_to_be_signed_in

        click_link 'My account'
        expect(page).to have_field('account_username', with: 'manuela-de-las-carmenas')

        visit edit_user_registration_path
        expect(page).to have_field('user_email', with: 'manueladelascarmenas@example.com')
      end

      scenario 'Sign in, user was already signed up with OAuth' do
        user = create(:user, email: 'manuela@madrid.es', password: 'judgementday')
        create(:identity, uid: '12345', provider: 'twitter', user: user)
        omniauth_twitter_hash = { 'provider' => 'twitter',
                                  'uid' => '12345',
                                  'info' => {
                                    'name' => 'manuela'
                                  }
                                }

        OmniAuth.config.add_mock(:twitter, omniauth_twitter_hash)

        visit '/'
        click_link 'Sign in'
        click_link 'Sign in with Twitter'

        expect_to_be_signed_in

        click_link 'My account'
        expect(page).to have_field('account_username', with: user.username)

        visit edit_user_registration_path
        expect(page).to have_field('user_email', with: user.email)

      end
    end
  end

  scenario 'Sign out' do
    user = create(:user)
    login_as(user)

    visit "/"
    click_link 'Sign out'

    expect(page).to have_content 'You have been signed out successfully.'
  end

  scenario 'Reset password' do
    create(:user, email: 'manuela@madrid.es')

    visit '/'
    click_link 'Sign in'
    click_link 'Forgotten your password?'

    fill_in 'user_email', with: 'manuela@madrid.es'
    click_button 'Send instructions'

    expect(page).to have_content "In a few minutes, you will receive an email containing instructions on resetting your password."

    sent_token = /.*reset_password_token=(.*)".*/.match(ActionMailer::Base.deliveries.last.body.to_s)[1]
    visit edit_user_password_path(reset_password_token: sent_token)

    fill_in 'user_password', with: 'new password'
    fill_in 'user_password_confirmation', with: 'new password'
    click_button 'Change my password'

    expect(page).to have_content "Your password has been changed successfully."
  end
end
