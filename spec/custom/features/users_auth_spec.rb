require 'rails_helper'

feature 'Users' do

  context 'Regular authentication' do
    context 'Sign up' do

      scenario 'Success' do
        message = "You have been sent a message containing a verification link. Please click on this link to activate your account."
        visit '/'

        # la duplication du menu pour mobile oblige à expliciter le lien que l'on cherche
        click_link('Register', match: :first)

        fill_in 'user_firstname',             with: "Manuela"
        fill_in 'user_lastname',              with: "Carmena"
        fill_in 'user_email',                 with: 'manuela@consul.dev'
        fill_in 'user_password',              with: 'judgementday'
        fill_in 'user_password_confirmation', with: 'judgementday'
        fill_in 'user_postal_code',           with: "11000"
        select_date "31-December-#{valid_date_of_birth_year}", from: 'user_date_of_birth'
        check 'user_terms_of_service'

        click_button 'Register'

        expect(page).to have_content message

        confirm_email

        expect(page).to have_content "Your account has been confirmed."
      end

      scenario 'Errors on sign up' do
        visit '/'
        click_link('Register', match: :first)
        click_button 'Register'

        expect(page).to have_content error_message
      end

    end

    context 'Sign in' do

      scenario 'sign in with email' do
        create(:user, email: 'manuela@consul.dev', password: 'judgementday')

        visit '/'
        click_link('Sign in', match: :first)
        fill_in 'user_login',    with: 'manuela@consul.dev'
        fill_in 'user_password', with: 'judgementday'
        click_button 'Enter'

        expect(page).to have_content 'You have been signed in successfully.'
      end

      scenario 'Sign in with username' do
        create(:user, username: '👻👽👾🤖', email: 'ash@nostromo.dev', password: 'xenomorph')

        visit '/'
        click_link('Sign in', match: :first)
        fill_in 'user_login',    with: '👻👽👾🤖'
        fill_in 'user_password', with: 'xenomorph'
        click_button 'Enter'

        expect(page).to have_content 'You have been signed in successfully.'
      end

      scenario 'Avoid username-email collisions' do
        u1 = create(:user, username: 'Spidey', email: 'peter@nyc.dev', password: 'greatpower')
        u2 = create(:user, username: 'peter@nyc.dev', email: 'venom@nyc.dev', password: 'symbiote')

        visit '/'
        click_link('Sign in', match: :first)
        fill_in 'user_login',    with: 'peter@nyc.dev'
        fill_in 'user_password', with: 'greatpower'
        click_button 'Enter'

        expect(page).to have_content 'You have been signed in successfully.'

        visit account_path

        expect(page).to have_link 'My activity', href: user_path(u1)

        visit '/'
        click_link('Sign out', match: :first)

        expect(page).to have_content 'You have been signed out successfully.'

        click_link('Sign in', match: :first)
        fill_in 'user_login',    with: 'peter@nyc.dev'
        fill_in 'user_password', with: 'symbiote'
        click_button 'Enter'

        expect(page).not_to have_content 'You have been signed in successfully.'
        expect(page).to have_content 'Invalid login or password.'

        fill_in 'user_login',    with: 'venom@nyc.dev'
        fill_in 'user_password', with: 'symbiote'
        click_button 'Enter'

        expect(page).to have_content 'You have been signed in successfully.'

        visit account_path

        expect(page).to have_link 'My activity', href: user_path(u2)
      end
    end
  end

  context 'OAuth authentication' do
    context 'Facebook' do

      let(:facebook_hash){ {provider: 'facebook', uid: '12345', info: {name: 'manuela'}} }
      let(:facebook_hash_with_email){ {provider: 'facebook', uid: '12345', info: {name: 'manuela', email: 'manuelacarmena@example.com'}} }
      let(:facebook_hash_with_verified_email) do
        {
          provider: 'facebook',
          uid: '12345',
          info: {
            name: 'manuela',
            email: 'manuelacarmena@example.com',
            verified: '1'
          }
        }
      end

      scenario 'Sign up when Oauth provider has a verified email' do
        OmniAuth.config.add_mock(:facebook, facebook_hash_with_verified_email)

        visit '/'
        click_link('Register', match: :first)

        click_link 'Sign up with Facebook'

        expect(page).to have_current_path(new_user_registration_path)
        fill_in_registration_fields_correctly
        click_button 'Register'

        expect_to_be_signed_in

        click_link('My account', match: :first)
        expect(page).to have_field('account_username', with: 'manuela')

        visit edit_user_registration_path
        expect(page).to have_field('user_email', with: 'manuelacarmena@example.com')
      end

      scenario 'Sign up when Oauth provider has an unverified email' do
        OmniAuth.config.add_mock(:facebook, facebook_hash_with_email)

        visit '/'
        click_link('Register', match: :first)

        click_link 'Sign up with Facebook'

        expect(page).to have_current_path(new_user_registration_path)
        fill_in_registration_fields_correctly
        click_button 'Register'

        expect(page).to have_content I18n.t("devise.registrations.signed_up_but_unconfirmed")

        confirm_email
        expect(page).to have_content "Your account has been confirmed"

        visit '/'
        click_link('Sign in', match: :first)
        click_link 'Sign in with Facebook'
        expect_to_be_signed_in

        click_link('My account', match: :first)
        expect(page).to have_field('account_username', with: 'manuela')

        visit edit_user_registration_path
        expect(page).to have_field('user_email', with: 'manuelacarmena@example.com')
      end

      scenario 'Sign up, when no email was provided by OAuth provider' do
        OmniAuth.config.add_mock(:facebook, facebook_hash)

        visit '/'
        click_link('Register', match: :first)
        click_link 'Sign up with Facebook'

        expect(page).to have_current_path(new_user_registration_path)
        fill_in_registration_fields_correctly
        fill_in 'user_email',             with: "manueladelascarmenas@example.com"
        click_button 'Register'

        expect(page).to have_content I18n.t("devise.registrations.signed_up_but_unconfirmed")

        confirm_email
        expect(page).to have_content "Your account has been confirmed"

        visit '/'
        click_link('Sign in', match: :first)
        click_link 'Sign in with Facebook'
        expect_to_be_signed_in

        click_link('My account', match: :first)
        expect(page).to have_field('account_username', with: 'manuela')

        visit edit_user_registration_path
        expect(page).to have_field('user_email', with: 'manueladelascarmenas@example.com')
      end

      scenario 'Sign in, user was already signed up with OAuth' do
        user = create(:user, email: 'manuela@consul.dev', password: 'judgementday')
        create(:identity, uid: '12345', provider: 'facebook', user: user)
        OmniAuth.config.add_mock(:facebook, facebook_hash)

        visit '/'
        click_link('Sign in', match: :first)
        click_link 'Sign in with Facebook'

        expect_to_be_signed_in

        click_link('My account', match: :first)
        expect(page).to have_field('account_username', with: user.username)

        visit edit_user_registration_path
        expect(page).to have_field('user_email', with: user.email)

      end

      scenario 'Try to register with the username of an already existing user' do
        create(:user, username: 'manuela', email: 'manuela@consul.dev', password: 'judgementday')
        OmniAuth.config.add_mock(:facebook, facebook_hash_with_verified_email)

        visit '/'
        click_link('Register', match: :first)
        click_link 'Sign up with Facebook'

        expect(page).to have_current_path(new_user_registration_path)
        fill_in_registration_fields_correctly
        expect(page).to have_field('user_username', with: 'manuela')

        click_button 'Register'

        expect(page).to have_current_path(user_registration_path)
        fill_in_registration_fields_correctly
        fill_in 'user_username', with: 'manuela2'
        click_button 'Register'

        expect_to_be_signed_in

        click_link('My account', match: :first)
        expect(page).to have_field('account_username', with: 'manuela2')

        visit edit_user_registration_path
        expect(page).to have_field('user_email', with: 'manuelacarmena@example.com')
      end

      scenario 'Try to register with the email of an already existing user, when no email was provided by oauth' do
        create(:user, username: 'peter', email: 'manuela@example.com')
        OmniAuth.config.add_mock(:facebook, facebook_hash)

        visit '/'
        click_link('Register', match: :first)
        click_link 'Sign up with Facebook'

        expect(page).to have_current_path(new_user_registration_path)
        fill_in_registration_fields_correctly
        fill_in 'user_email', with: 'manuela@example.com'
        click_button 'Register'

        expect(page).to have_current_path(user_registration_path)
        fill_in_registration_fields_correctly
        fill_in 'user_email', with: 'somethingelse@example.com'
        click_button 'Register'

        expect(page).to have_content I18n.t("devise.registrations.signed_up_but_unconfirmed")

        confirm_email
        expect(page).to have_content "Your account has been confirmed"

        visit '/'
        click_link('Sign in', match: :first)
        click_link 'Sign in with Facebook'
        expect_to_be_signed_in

        click_link('My account', match: :first)
        expect(page).to have_field('account_username', with: 'manuela')

        visit edit_user_registration_path
        expect(page).to have_field('user_email', with: 'somethingelse@example.com')
      end

      scenario 'Try to register with the email of an already existing user, when an unconfirmed email was provided by oauth' do
        create(:user, username: 'peter', email: 'manuelacarmena@example.com')
        OmniAuth.config.add_mock(:facebook, facebook_hash_with_email)

        visit '/'
        click_link('Register', match: :first)
        click_link 'Sign up with Facebook'

        expect(page).to have_current_path(new_user_registration_path)

        expect(page).to have_field('user_email', with: 'manuelacarmena@example.com')
        fill_in_registration_fields_correctly
        fill_in 'user_email', with: 'somethingelse@example.com'
        click_button 'Register'

        expect(page).to have_content I18n.t("devise.registrations.signed_up_but_unconfirmed")

        confirm_email
        expect(page).to have_content "Your account has been confirmed"

        visit '/'
        click_link('Sign in', match: :first)
        click_link 'Sign in with Facebook'
        expect_to_be_signed_in

        click_link('My account', match: :first)
        expect(page).to have_field('account_username', with: 'manuela')

        visit edit_user_registration_path
        expect(page).to have_field('user_email', with: 'somethingelse@example.com')
      end
    end
  end

  scenario 'Sign out' do
    user = create(:user)
    login_as(user)

    visit "/"
    click_link('Sign out', match: :first)

    expect(page).to have_content 'You have been signed out successfully.'
  end

  scenario 'Reset password' do
    create(:user, email: 'manuela@consul.dev')

    visit '/'
    click_link('Sign in', match: :first)
    click_link 'Forgotten your password?'

    fill_in 'user_email', with: 'manuela@consul.dev'
    click_button 'Send instructions'

    expect(page).to have_content "In a few minutes, you will receive an email containing instructions on resetting your password."

    sent_token = /.*reset_password_token=(.*)".*/.match(ActionMailer::Base.deliveries.last.body.to_s)[1]
    visit edit_user_password_path(reset_password_token: sent_token)

    fill_in 'user_password', with: 'new password'
    fill_in 'user_password_confirmation', with: 'new password'
    click_button 'Change my password'

    expect(page).to have_content "Your password has been changed successfully."
  end

  # TODO i18n : broken because of test locale change
  scenario 'Sign in, admin with password expired' do
    user = create(:user, password_changed_at: Time.current - 1.year)
    admin = create(:administrator, user: user)

    login_as(admin.user)
    visit root_path

    expect(page).to have_content "Your password is expired"

    fill_in 'user_current_password', with: 'judgmentday'
    fill_in 'user_password', with: '123456789'
    fill_in 'user_password_confirmation', with: '123456789'

    click_button 'Change your password'

    expect(page).to have_content "Password successfully updated"
  end

  scenario 'Sign in, admin without password expired' do
    user = create(:user, password_changed_at: Time.current - 360.days)
    admin = create(:administrator, user: user)

    login_as(admin.user)
    visit root_path

    expect(page).not_to have_content "Your password is expired"
  end

  scenario 'Sign in, user with password expired' do
    user = create(:user, password_changed_at: Time.current - 1.year)

    login_as(user)
    visit root_path

    expect(page).not_to have_content "Your password is expired"
  end


  # TODO i18n : broken because of test locale change
  scenario 'Admin with password expired trying to use same password' do
    user = create(:user, password_changed_at: Time.current - 1.year, password: '123456789')
    admin = create(:administrator, user: user)

    login_as(admin.user)
    visit root_path

    expect(page).to have_content "Your password is expired"

    fill_in 'user_current_password', with: 'judgmentday'
    fill_in 'user_password', with: '123456789'
    fill_in 'user_password_confirmation', with: '123456789'
    click_button 'Change your password'

    expect(page).to have_content "must be different than the current password."
  end

  def fill_in_registration_fields_correctly
    fill_in 'user_firstname',             with: "Manuela"
    fill_in 'user_lastname',              with: "Carmena"
    select_date "31-December-#{valid_date_of_birth_year}", from: 'user_date_of_birth'
    fill_in 'user_postal_code',           with: "11000"
    fill_in 'user_password',              with: "password"
    fill_in 'user_password_confirmation', with: "password"
    check 'user_terms_of_service'
  end

end
