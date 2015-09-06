require 'rails_helper'

feature 'Users' do

  context 'Regular authentication' do
    scenario 'Sign up' do
      visit '/'
      click_link 'Sign up'

      fill_in 'user_username',              with: 'Manuela Carmena'
      fill_in 'user_email',                 with: 'manuela@madrid.es'
      fill_in 'user_password',              with: 'judgementday'
      fill_in 'user_password_confirmation', with: 'judgementday'
      fill_in 'user_captcha',               with: correct_captcha_text
      check 'user_terms_of_service'

      click_button 'Sign up'

      expect(page).to have_content "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."

      sent_token = /.*confirmation_token=(.*)".*/.match(ActionMailer::Base.deliveries.last.body.to_s)[1]
      visit user_confirmation_path(confirmation_token: sent_token)

      expect(page).to have_content "Your email address has been successfully confirmed"
    end

    scenario 'Errors on sign up' do
      visit '/'
      click_link 'Sign up'
      click_button 'Sign up'

      expect(page).to have_content error_message
    end

    scenario 'Sign in' do
      create(:user, email: 'manuela@madrid.es', password: 'judgementday')

      visit '/'
      click_link 'Log in'
      fill_in 'user_email',    with: 'manuela@madrid.es'
      fill_in 'user_password', with: 'judgementday'
      click_button 'Log in'

      expect(page).to have_content 'Signed in successfully.'
    end
  end

  xcontext 'OAuth authentication' do
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
        click_link 'Sign up'

        expect do
          expect do
            expect do
              click_link 'Sign up with Twitter'
            end.not_to change { ActionMailer::Base.deliveries.size }
          end.to change { Identity.count }.by(1)
        end.to change { User.count }.by(1)

        expect(current_path).to eq(root_path)
        expect_to_be_signed_in

        user = User.last
        expect(user.username).to eq('ManuelaRocks')
        expect(user.email).to eq('manuelacarmena@example.com')
        expect(user.confirmed?).to eq(true)
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
        click_link 'Sign up'

        expect do
          expect do
            expect do
              click_link 'Sign up with Twitter'
            end.not_to change { ActionMailer::Base.deliveries.size }
          end.to change { Identity.count }.by(1)
        end.to change { User.count }.by(1)

        expect(current_path).to eq(finish_signup_path)

        user = User.last
        expect(user.username).to eq('manuela-de-las-carmenas')
        expect(user.email).to eq("omniauth@participacion-12345-twitter.com")

        fill_in 'user_email', with: 'manueladelascarmenas@example.com'
        click_button 'Sign up'

        sent_token = /.*confirmation_token=(.*)".*/.match(ActionMailer::Base.deliveries.last.body.to_s)[1]
        visit user_confirmation_path(confirmation_token: sent_token)

        expect(page).to have_content "Your email address has been successfully confirmed"

        expect(user.reload.email).to eq('manueladelascarmenas@example.com')
      end

      scenario 'Sign in, user was already signed up with OAuth' do
        user = create(:user, email: 'manuela@madrid.es', password: 'judgementday')
        identity = create(:identity, uid: '12345', provider: 'twitter', user: user)
        omniauth_twitter_hash = { 'provider' => 'twitter',
                                  'uid' => '12345',
                                  'info' => {
                                    'name' => 'manuela'
                                  }
                                }

        OmniAuth.config.add_mock(:twitter, omniauth_twitter_hash)

        visit '/'
        click_link 'Log in'

        expect do
          expect do
            click_link 'Sign in with Twitter'
          end.not_to change { Identity.count }
        end.not_to change { User.count }

        expect_to_be_signed_in
      end
    end
  end

  scenario 'Sign out' do
    user = create(:user)
    login_as(user)

    visit "/"
    click_link 'Logout'

    expect(page).to have_content 'Signed out successfully.'
  end

  scenario 'Reset password' do
    create(:user, email: 'manuela@madrid.es')

    visit '/'
    click_link 'Log in'
    click_link 'Forgot your password?'

    fill_in 'user_email', with: 'manuela@madrid.es'
    click_button 'Send me reset password instructions'

    expect(page).to have_content "You will receive an email with instructions on how to reset your password in a few minutes."

    sent_token = /.*reset_password_token=(.*)".*/.match(ActionMailer::Base.deliveries.last.body.to_s)[1]
    visit edit_user_password_path(reset_password_token: sent_token)

    fill_in 'user_password', with: 'new password'
    fill_in 'user_password_confirmation', with: 'new password'
    click_button 'Change my password'

    expect(page).to have_content "Your password has been changed successfully. You are now signed in."
  end
end
