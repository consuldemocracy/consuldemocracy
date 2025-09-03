require "rails_helper"

describe "Users" do
  context "Regular authentication" do
    context "Sign up" do
      scenario "Success" do
        message = "You have been sent a message containing a verification link. " \
                  "Please click on this link to activate your account."
        visit "/"
        click_link "Register"

        fill_in "Username", with: "Manuela Carmena"
        fill_in "Email", with: "manuela@consul.dev"
        fill_in "Password", with: "judgementday"
        fill_in "Confirm password", with: "judgementday"
        check "user_terms_of_service"

        click_button "Register"

        expect(page).to have_content message

        confirm_email

        expect(page).to have_content "Your account has been confirmed."
      end

      scenario "Errors on sign up" do
        visit "/"
        click_link "Register"
        click_button "Register"

        expect(page).to have_content error_message
      end

      scenario "User already confirmed email with the token" do
        message = "You have been sent a message containing a verification link. " \
                  "Please click on this link to activate your account."
        visit "/"
        click_link "Register"

        fill_in "Username", with: "Manuela Carmena"
        fill_in "Email", with: "manuela@consul.dev"
        fill_in "Password", with: "judgementday"
        fill_in "Confirm password", with: "judgementday"
        check "user_terms_of_service"

        click_button "Register"

        expect(page).to have_content message

        confirm_email
        expect(page).to have_content "Your account has been confirmed."

        sent_token = /.*confirmation_token=(.*)".*/.match(ActionMailer::Base.deliveries.last.body.to_s)[1]
        visit user_confirmation_path(confirmation_token: sent_token)

        expect(page).to have_content "You have already been verified; please attempt to sign in."
      end
    end

    context "Sign in" do
      scenario "sign in with email" do
        create(:user, email: "manuela@consul.dev", password: "judgementday")

        login_through_form_with("manuela@consul.dev", password: "judgementday")

        expect(page).to have_content "You have been signed in successfully."
      end

      scenario "Sign in with username" do
        create(:user, username: "中村広", email: "ash@nostromo.dev", password: "xenomorph")

        login_through_form_with("中村広", password: "xenomorph")

        expect(page).to have_content "You have been signed in successfully."
      end

      scenario "Avoid username-email collisions" do
        u1 = create(:user, username: "Spidey", email: "peter@nyc.dev", password: "greatpower")
        u2 = create(:user, username: "peter@nyc.dev", email: "venom@nyc.dev", password: "symbiote")

        login_through_form_with("peter@nyc.dev", password: "greatpower")

        expect(page).to have_content "You have been signed in successfully."
        expect(page).to have_link "My content", href: user_path(u1)

        within("#notice") { click_button "Close" }
        click_button "Sign out"

        expect(page).to have_content "You have been signed out successfully."

        login_through_form_with("peter@nyc.dev", password: "symbiote")

        expect(page).not_to have_content "You have been signed in successfully."
        expect(page).to have_content "Invalid Email or username or password."

        fill_in "Email or username", with: "venom@nyc.dev"
        fill_in "Password", with: "symbiote"
        click_button "Enter"

        expect(page).to have_content "You have been signed in successfully."

        visit account_path

        expect(page).to have_link "My content", href: user_path(u2)
      end
    end
  end

  context "OAuth authentication" do
    context "Twitter" do
      let(:twitter_hash) { { uid: "12345", info: { name: "manuela" }} }
      let(:twitter_hash_with_email) do
        { uid: "12345", info: { name: "manuela", email: "manuelacarmena@example.com" }}
      end
      let(:twitter_hash_with_verified_email) do
        {
          uid: "12345",
          info: {
            name: "manuela",
            email: "manuelacarmena@example.com",
            verified: "1"
          }
        }
      end

      scenario "Sign up when Oauth provider has a verified email" do
        OmniAuth.config.add_mock(:twitter, twitter_hash_with_verified_email)

        visit "/"
        click_link "Register"

        click_button "Sign up with Twitter"

        expect_to_be_signed_in

        within("#notice") { click_button "Close" }
        click_link "My account"

        expect(page).to have_field "Username", with: "manuela"

        visit edit_user_registration_path
        expect(page).to have_field "Email", with: "manuelacarmena@example.com"
      end

      scenario "Sign up when Oauth provider has an unverified email" do
        OmniAuth.config.add_mock(:twitter, twitter_hash_with_email)

        visit "/"
        click_link "Register"

        click_button "Sign up with Twitter"

        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content "To continue, please click on the confirmation " \
                                     "link that we have sent you via email"

        confirm_email
        expect(page).to have_content "Your account has been confirmed"

        visit "/"
        click_link "Sign in"
        click_button "Sign in with Twitter"
        expect_to_be_signed_in

        within("#notice") { click_button "Close" }
        click_link "My account"

        expect(page).to have_field "Username", with: "manuela"

        visit edit_user_registration_path
        expect(page).to have_field "Email", with: "manuelacarmena@example.com"
      end

      scenario "Sign up, when no email was provided by OAuth provider" do
        OmniAuth.config.add_mock(:twitter, twitter_hash)

        visit "/"
        click_link "Register"
        click_button "Sign up with Twitter"

        expect(page).to have_current_path(finish_signup_path)
        fill_in "Email", with: "manueladelascarmenas@example.com"
        click_button "Register"

        expect(page).to have_content "To continue, please click on the confirmation " \
                                     "link that we have sent you via email"

        confirm_email
        expect(page).to have_content "Your account has been confirmed"

        visit "/"
        click_link "Sign in"
        click_button "Sign in with Twitter"
        expect_to_be_signed_in

        within("#notice") { click_button "Close" }
        click_link "My account"

        expect(page).to have_field "Username", with: "manuela"

        visit edit_user_registration_path
        expect(page).to have_field "Email", with: "manueladelascarmenas@example.com"
      end

      scenario "Cancelling signup" do
        OmniAuth.config.add_mock(:twitter, twitter_hash)

        visit "/"
        click_link "Register"
        click_button "Sign up with Twitter"

        expect(page).to have_current_path(finish_signup_path)
        click_button "Cancel login"

        expect(page).to have_content "You have been signed out successfully"

        visit "/"

        expect(page).not_to have_content "You have been signed out successfully"
        expect_not_to_be_signed_in
      end

      scenario "Sign in, user was already signed up with OAuth" do
        user = create(:user, email: "manuela@consul.dev", password: "judgementday")
        create(:identity, uid: "12345", provider: "twitter", user: user)
        OmniAuth.config.add_mock(:twitter, twitter_hash)

        visit "/"
        click_link "Sign in"
        click_button "Sign in with Twitter"

        expect_to_be_signed_in

        within("#notice") { click_button "Close" }
        click_link "My account"

        expect(page).to have_field "Username", with: user.username

        visit edit_user_registration_path
        expect(page).to have_field "Email", with: user.email
      end

      scenario "Try to register with verified email and with the username of an already existing user" do
        create(:user, username: "manuela", email: "manuela@consul.dev", password: "judgementday")
        OmniAuth.config.add_mock(:twitter, twitter_hash_with_verified_email)

        visit "/"
        click_link "Register"
        click_button "Sign up with Twitter"

        expect(page).to have_current_path(finish_signup_path)

        expect(page).to have_field "Username", with: "manuela"

        click_button "Register"

        expect(page).to have_current_path(do_finish_signup_path)

        fill_in "Username", with: "manuela2"
        click_button "Register"

        expect_to_be_signed_in

        click_link "My account"
        expect(page).to have_field "Username", with: "manuela2"

        visit edit_user_registration_path
        expect(page).to have_field "Email", with: "manuelacarmena@example.com"
      end

      scenario "Try to register with unverified email and with the username of an already existing user" do
        create(:user, username: "manuela", email: "manuela@consul.dev", password: "judgementday")
        OmniAuth.config.add_mock(:twitter, twitter_hash_with_email)

        visit "/"
        click_link "Register"
        click_button "Sign up with Twitter"

        expect(page).to have_current_path(finish_signup_path)
        expect(page).to have_field "Username", with: "manuela"

        click_button "Register"

        expect(page).to have_current_path(do_finish_signup_path)

        fill_in "Username", with: "manuela2"
        click_button "Register"

        expect(page).to have_content "To continue, please click on the confirmation " \
                                     "link that we have sent you via email"

        confirm_email

        expect(page).to have_content "Your account has been confirmed"

        visit "/"
        click_link "Sign in"
        click_button "Sign in with Twitter"

        within("#notice") { click_button "Close" }
        click_link "My account"
        expect(page).to have_field "Username", with: "manuela2"

        visit edit_user_registration_path
        expect(page).to have_field "Email", with: "manuelacarmena@example.com"
      end

      scenario "Try to register with an existing email, when no email was provided by oauth" do
        create(:user, username: "peter", email: "manuela@example.com")
        OmniAuth.config.add_mock(:twitter, twitter_hash)

        visit "/"
        click_link "Register"
        click_button "Sign up with Twitter"

        expect(page).to have_current_path(finish_signup_path)

        fill_in "Email", with: "manuela@example.com"
        click_button "Register"

        expect(page).to have_current_path(do_finish_signup_path)

        fill_in "Email", with: "somethingelse@example.com"
        click_button "Register"

        expect(page).to have_content "To continue, please click on the confirmation " \
                                     "link that we have sent you via email"

        confirm_email
        expect(page).to have_content "Your account has been confirmed"

        visit "/"
        click_link "Sign in"
        click_button "Sign in with Twitter"
        expect_to_be_signed_in

        within("#notice") { click_button "Close" }
        click_link "My account"

        expect(page).to have_field "Username", with: "manuela"

        visit edit_user_registration_path
        expect(page).to have_field "Email", with: "somethingelse@example.com"
      end

      scenario "Try to register with an existing email, when an unconfirmed email was provided by oauth" do
        create(:user, username: "peter", email: "manuelacarmena@example.com")
        OmniAuth.config.add_mock(:twitter, twitter_hash_with_email)

        visit "/"
        click_link "Register"
        click_button "Sign up with Twitter"

        expect(page).to have_current_path(finish_signup_path)

        expect(page).to have_field "Email", with: "manuelacarmena@example.com"
        fill_in "Email", with: "somethingelse@example.com"
        click_button "Register"

        expect(page).to have_content "To continue, please click on the confirmation " \
                                     "link that we have sent you via email"

        confirm_email
        expect(page).to have_content "Your account has been confirmed"

        visit "/"
        click_link "Sign in"
        click_button "Sign in with Twitter"
        expect_to_be_signed_in

        within("#notice") { click_button "Close" }
        click_link "My account"

        expect(page).to have_field "Username", with: "manuela"

        visit edit_user_registration_path
        expect(page).to have_field "Email", with: "somethingelse@example.com"
      end
    end

    context "Google" do
      let(:google_hash) do
        {
          uid: "12345",
          info: {
            name: "manuela",
            email: "manuelacarmena@example.com",
            email_verified: "1"
          }
        }
      end

      before { Setting["feature.google_login"] = true }

      scenario "Sign in with an already registered user using a verified google account" do
        OmniAuth.config.add_mock(:google_oauth2, google_hash)
        create(:user, username: "manuela", email: "manuelacarmena@example.com")

        visit new_user_session_path
        click_button "Sign in with Google"

        expect_to_be_signed_in
      end
    end

    context "Wordpress" do
      let(:wordpress_hash) do
        {
          uid: "12345",
          info: {
            name: "manuela",
            email: "manuelacarmena@example.com"
          }
        }
      end

      before { Setting["feature.wordpress_login"] = true }

      scenario "Sign up" do
        OmniAuth.config.add_mock(:wordpress_oauth2, wordpress_hash)

        visit "/"
        click_link "Register"

        click_button "Sign up with Wordpress"

        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content "To continue, please click on the confirmation " \
                                     "link that we have sent you via email"

        confirm_email
        expect(page).to have_content "Your account has been confirmed"

        visit "/"
        click_link "Sign in"
        click_button "Sign in with Wordpress"
        expect_to_be_signed_in

        within("#notice") { click_button "Close" }
        click_link "My account"

        expect(page).to have_field "Username", with: "manuela"

        visit edit_user_registration_path
        expect(page).to have_field "Email", with: "manuelacarmena@example.com"
      end

      scenario "Try to register with username and email of an already existing user" do
        create(:user, username: "manuela", email: "manuelacarmena@example.com", password: "judgementday")
        OmniAuth.config.add_mock(:wordpress_oauth2, wordpress_hash)

        visit "/"
        click_link "Register"
        click_button "Sign up with Wordpress"

        expect(page).to have_current_path(finish_signup_path)

        expect(page).to have_field "Username", with: "manuela"

        click_button "Register"

        expect(page).to have_current_path(do_finish_signup_path)

        fill_in "Username", with: "manuela2"
        fill_in "Email", with: "manuela@consul.dev"
        click_button "Register"

        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content "To continue, please click on the confirmation " \
                                     "link that we have sent you via email"

        confirm_email
        expect(page).to have_content "Your account has been confirmed"

        visit "/"
        click_link "Sign in"
        click_button "Sign in with Wordpress"

        expect_to_be_signed_in

        within("#notice") { click_button "Close" }
        click_link "My account"

        expect(page).to have_field "Username", with: "manuela2"

        visit edit_user_registration_path
        expect(page).to have_field "Email", with: "manuela@consul.dev"
      end
    end

    context "Saml" do
      before { Setting["feature.saml_login"] = true }

      let(:saml_hash_with_email) do
        {
          provider: "saml",
          uid: "ext-tester",
          info: {
            name: "samltester",
            email: "tester@consul.dev"
          }
        }
      end

      let(:saml_hash_with_verified_email) do
        {
          provider: "saml",
          uid: "ext-tester",
          info: {
            name: "samltester",
            email: "tester@consul.dev",
            verified: "1"
          }
        }
      end

      scenario "Sign up with a confirmed email" do
        OmniAuth.config.add_mock(:saml, saml_hash_with_verified_email)

        visit new_user_registration_path
        click_button "Sign up with SAML"

        expect(page).to have_content "Successfully identified as Saml"
        expect_to_be_signed_in

        within("#notice") { click_button "Close" }
        click_link "My account"

        expect(page).to have_field "Username", with: "samltester"

        click_link "Change my login details"

        expect(page).to have_field "Email", with: "tester@consul.dev"
      end

      scenario "Sign up with an unconfirmed email" do
        OmniAuth.config.add_mock(:saml, saml_hash_with_email)

        visit new_user_registration_path
        click_button "Sign up with SAML"

        expect(page).to have_content "To continue, please click on the confirmation " \
                                     "link that we have sent you via email"

        confirm_email
        expect(page).to have_content "Your account has been confirmed"
        expect(page).to have_current_path new_user_session_path

        click_button "Sign in with SAML"

        expect(page).to have_content "Successfully identified as Saml"
        expect_to_be_signed_in

        within("#notice") { click_button "Close" }
        click_link "My account"

        expect(page).to have_field "Username", with: "samltester"

        click_link "Change my login details"

        expect(page).to have_field "Email", with: "tester@consul.dev"
      end

      scenario "Sign in with a user with a SAML identity" do
        user = create(:user, username: "samltester", email: "tester@consul.dev", password: "My123456")
        create(:identity, uid: "ext-tester", provider: "saml", user: user)
        OmniAuth.config.add_mock(:saml, { provider: "saml", uid: "ext-tester" })

        visit new_user_session_path
        click_button "Sign in with SAML"

        expect(page).to have_content "Successfully identified as Saml"
        expect_to_be_signed_in

        within("#notice") { click_button "Close" }
        click_link "My account"

        expect(page).to have_field "Username", with: "samltester"

        click_link "Change my login details"

        expect(page).to have_field "Email", with: "tester@consul.dev"
      end

      scenario "Sign in with a user without a SAML identity keeps the username" do
        create(:user, username: "tester", email: "tester@consul.dev", password: "My123456")
        OmniAuth.config.add_mock(:saml, saml_hash_with_verified_email)

        visit new_user_session_path
        click_button "Sign in with SAML"

        expect(page).to have_content "Successfully identified as Saml"
        expect_to_be_signed_in

        within("#notice") { click_button "Close" }
        click_link "My account"

        expect(page).to have_field "Username", with: "tester"

        click_link "Change my login details"

        expect(page).to have_field "Email", with: "tester@consul.dev"
      end

      scenario "SAML user from one tenant cannot sign in to another tenant", :seed_tenants do
        %w[mars venus].each do |schema|
          create(:tenant, schema: schema)
          Tenant.switch(schema) { Setting["feature.saml_login"] = true }
        end

        Tenant.switch("mars") do
          mars_user = create(:user, username: "marsuser", email: "mars@consul.dev")
          create(:identity, uid: "mars-saml-123", provider: "saml", user: mars_user)
        end

        mars_saml_hash = {
          provider: "saml",
          uid: "mars-saml-123",
          info: {
            name: "marsuser",
            email: "mars@consul.dev"
          }
        }
        OmniAuth.config.add_mock(:saml, mars_saml_hash)

        with_subdomain("mars") do
          visit new_user_session_path
          click_button "Sign in with SAML"

          expect(page).to have_content "Successfully identified as Saml"

          within("#notice") { click_button "Close" }
          click_link "My account"

          expect(page).to have_field "Username", with: "marsuser"
        end

        with_subdomain("venus") do
          visit new_user_session_path
          click_button "Sign in with SAML"

          expect(page).to have_content "To continue, please click on the confirmation " \
                                       "link that we have sent you via email"
        end
      end
    end

    context "OIDC" do
      before { Setting["feature.oidc_login"] = true }

      let(:oidc_hash_unverified_email) do
        {
          provider: "oidc",
          uid: "oidc-user-123",
          info: {
            name: "oidctester",
            email: "tester@consul.dev"
          }
        }
      end

      let(:oidc_hash_with_verified_email) do
        {
          provider: "oidc",
          uid: "oidc-user-123",
          info: {
            name: "oidctester",
            email: "tester@consul.dev",
            verified: "1"
          }
        }
      end

      scenario "Sign up with a confirmed email from OIDC provider" do
        OmniAuth.config.add_mock(:oidc, oidc_hash_with_verified_email)

        visit new_user_registration_path
        click_button "Sign up with OIDC"

        expect(page).to have_content "Successfully identified as Oidc"
        expect_to_be_signed_in

        within("#notice") { click_button "Close" }
        click_link "My account"

        expect(page).to have_field "Username", with: "oidctester"

        click_link "Change my login details"

        expect(page).to have_field "Email", with: "tester@consul.dev"
      end

      scenario "Sign up with an unconfirmed email from OIDC provider" do
        OmniAuth.config.add_mock(:oidc, oidc_hash_unverified_email)

        visit new_user_registration_path
        click_button "Sign up with OIDC"

        expect(page).to have_content "To continue, please click on the confirmation " \
                                     "link that we have sent you via email"

        confirm_email
        expect(page).to have_content "Your account has been confirmed"
        expect(page).to have_current_path new_user_session_path

        click_button "Sign in with OIDC"

        expect(page).to have_content "Successfully identified as Oidc"
        expect_to_be_signed_in

        within("#notice") { click_button "Close" }
        click_link "My account"

        expect(page).to have_field "Username", with: "oidctester"

        click_link "Change my login details"

        expect(page).to have_field "Email", with: "tester@consul.dev"
      end

      scenario "Sign in with a user with an OIDC identity" do
        user = create(:user, username: "oidctester", email: "tester@consul.dev", password: "My123456")
        create(:identity, uid: "oidc-user-123", provider: "oidc", user: user)
        OmniAuth.config.add_mock(:oidc, { provider: "oidc", uid: "oidc-user-123" })

        visit new_user_session_path
        click_button "Sign in with OIDC"

        expect(page).to have_content "Successfully identified as Oidc"
        expect_to_be_signed_in

        within("#notice") { click_button "Close" }
        click_link "My account"

        expect(page).to have_field "Username", with: "oidctester"

        click_link "Change my login details"

        expect(page).to have_field "Email", with: "tester@consul.dev"
      end

      scenario "Sign in with a user without an OIDC identity keeps the username" do
        create(:user, username: "tester", email: "tester@consul.dev", password: "My123456")
        OmniAuth.config.add_mock(:oidc, oidc_hash_with_verified_email)

        visit new_user_session_path
        click_button "Sign in with OIDC"

        expect(page).to have_content "Successfully identified as Oidc"
        expect_to_be_signed_in

        within("#notice") { click_button "Close" }
        click_link "My account"

        expect(page).to have_field "Username", with: "tester"

        click_link "Change my login details"

        expect(page).to have_field "Email", with: "tester@consul.dev"
      end

      scenario "OIDC user from one tenant cannot sign in to another tenant", :seed_tenants do
        %w[mars venus].each do |schema|
          create(:tenant, schema: schema)
          Tenant.switch(schema) { Setting["feature.oidc_login"] = true }
        end

        Tenant.switch("mars") do
          mars_user = create(:user, username: "marsuser", email: "mars@consul.dev")
          create(:identity, uid: "mars-oidc-123", provider: "oidc", user: mars_user)
        end

        mars_oidc_hash = {
          provider: "oidc",
          uid: "mars-oidc-123",
          info: {
            name: "marsuser",
            email: "mars@consul.dev"
          }
        }

        OmniAuth.config.add_mock(:oidc, mars_oidc_hash)

        with_subdomain("mars") do
          visit new_user_session_path
          click_button "Sign in with OIDC"

          expect(page).to have_content "Successfully identified as Oidc"

          within("#notice") { click_button "Close" }
          click_link "My account"

          expect(page).to have_field "Username", with: "marsuser"
        end

        with_subdomain("venus") do
          visit new_user_session_path
          click_button "Sign in with OIDC"

          expect(page).to have_content "To continue, please click on the confirmation " \
                                       "link that we have sent you via email"
        end
      end

      scenario "Allows user authentication when OIDC token has expired" do
        user = create(:user, username: "oidctester", email: "tester@consul.dev")
        create(:identity, uid: "oidc-user-123", provider: "oidc", user: user)

        expired_oidc_hash = oidc_hash_with_verified_email.merge(
          credentials: {
            token: "expired_token",
            expires_at: 1.hour.ago.to_i,
            expires: true
          }
        )

        OmniAuth.config.add_mock(:oidc, expired_oidc_hash)

        visit new_user_session_path
        click_button "Sign in with OIDC"

        expect(page).to have_content "Successfully identified as Oidc"
        expect_to_be_signed_in
      end

      scenario "Handle missing email claim from OIDC provider" do
        oidc_hash_no_email = {
          provider: "oidc",
          uid: "oidc-user-no-email",
          info: {
            name: "noemailuser"
          }
        }

        OmniAuth.config.add_mock(:oidc, oidc_hash_no_email)

        visit new_user_registration_path
        click_button "Sign up with OIDC"

        expect(page).to have_content "1 error prevented this Account from being saved."

        expect(page).to have_content "can't be blank"
      end
    end
  end

  scenario "Sign out" do
    user = create(:user)
    login_as(user)

    visit "/"
    click_button "Sign out"

    expect(page).to have_content "You have been signed out successfully."
  end

  scenario "Reset password" do
    create(:user, email: "manuela@consul.dev")

    visit "/"
    click_link "Sign in"
    click_link "Forgotten your password?"

    fill_in "Email", with: "manuela@consul.dev"
    click_button "Send instructions"

    expect(page).to have_content "If your email address is in our database, in a few minutes " \
                                 "you will receive a link to use to reset your password."

    action_mailer = ActionMailer::Base.deliveries.last.body.to_s
    sent_token = /.*reset_password_token=(.*)".*/.match(action_mailer)[1]
    visit edit_user_password_path(reset_password_token: sent_token)

    fill_in "New password", with: "new password"
    fill_in "Confirm new password", with: "new password"
    click_button "Change my password"

    expect(page).to have_content "Your password has been changed successfully."
  end

  scenario "Reset password with unexisting email" do
    visit "/"
    click_link "Sign in"
    click_link "Forgotten your password?"

    fill_in "Email", with: "fake@mail.dev"
    click_button "Send instructions"

    expect(page).to have_content "If your email address is in our database, in a few minutes " \
                                 "you will receive a link to use to reset your password."
  end

  scenario "Re-send confirmation instructions" do
    create(:user, email: "manuela@consul.dev", confirmed_at: nil)
    ActionMailer::Base.deliveries.clear

    visit "/"
    click_link "Sign in"
    click_link "Haven't received instructions to activate your account?"

    fill_in "Email", with: "manuela@consul.dev"
    click_button "Re-send instructions"

    expect(page).to have_content "If your email address exists in our database, in a few minutes you will " \
                                 "receive an email with instructions on how to confirm your email address."
    expect(ActionMailer::Base.deliveries.count).to eq(1)
    expect(ActionMailer::Base.deliveries.first.to).to eq(["manuela@consul.dev"])
    expect(ActionMailer::Base.deliveries.first.subject).to eq("Confirmation instructions")
  end

  scenario "Re-send confirmation instructions with unexisting email" do
    ActionMailer::Base.deliveries.clear
    visit "/"
    click_link "Sign in"
    click_link "Haven't received instructions to activate your account?"

    fill_in "Email", with: "fake@mail.dev"
    click_button "Re-send instructions"

    expect(page).to have_content "If your email address exists in our database, in a few minutes you will " \
                                 "receive an email with instructions on how to confirm your email address."
    expect(ActionMailer::Base.deliveries.count).to eq(0)
  end

  scenario "Re-send confirmation instructions with already verified email" do
    ActionMailer::Base.deliveries.clear

    create(:user, email: "manuela@consul.dev")

    visit new_user_session_path
    click_link "Haven't received instructions to activate your account?"

    fill_in "user_email", with: "manuela@consul.dev"
    click_button "Re-send instructions"

    expect(page).to have_content "If your email address exists in our database, in a few minutes you will " \
                                 "receive an email with instructions on how to confirm your email address."
    expect(ActionMailer::Base.deliveries.count).to eq(1)
    expect(ActionMailer::Base.deliveries.first.to).to eq(["manuela@consul.dev"])
    expect(ActionMailer::Base.deliveries.first.subject).to eq("Your account is already confirmed")
  end

  scenario "Sign in, admin with password expired" do
    user = create(:administrator).user
    user.update!(password_changed_at: 1.year.ago)

    login_through_form_as(user)

    expect(page).to have_content "Your password is expired"

    fill_in "Current password", with: "judgmentday"
    fill_in "New password", with: "123456789"
    fill_in "Password confirmation", with: "123456789"

    click_button "Change your password"

    expect(page).to have_content "Password successfully updated"
  end

  scenario "Sign in, admin without password expired" do
    user = create(:user, password_changed_at: 360.days.ago)
    admin = create(:administrator, user: user)

    login_as(admin.user)
    visit root_path

    expect(page).not_to have_content "Your password is expired"
  end

  scenario "Sign in, user with password expired" do
    user = create(:user, password_changed_at: 1.year.ago)

    login_as(user)
    visit root_path

    expect(page).not_to have_content "Your password is expired"
  end

  scenario "Admin with password expired trying to use same password" do
    user = create(:administrator).user
    user.update!(password_changed_at: 1.year.ago, password: "123456789")

    login_through_form_as(user)

    expect(page).to have_content "Your password is expired"

    fill_in "Current password", with: "123456789"
    fill_in "New password", with: "123456789"
    fill_in "Password confirmation", with: "123456789"
    click_button "Change your password"

    expect(page).to have_content "must be different than the current password."
  end

  context "Regular authentication with password complexity enabled" do
    before do
      stub_secrets(security: { password_complexity: true })
    end

    context "Sign up" do
      scenario "Success with password" do
        message = "You have been sent a message containing a verification link. Please click on this" \
                  " link to activate your account."
        visit "/"
        click_link "Register"

        fill_in "Username", with: "Manuela Carmena"
        fill_in "Email", with: "manuela@consul.dev"
        fill_in "Password", with: "ValidPassword1234"
        fill_in "Confirm password", with: "ValidPassword1234"
        check "user_terms_of_service"

        click_button "Register"

        expect(page).to have_content message

        confirm_email

        expect(page).to have_content "Your account has been confirmed."
      end

      scenario "Errors on sign up" do
        visit "/"
        click_link "Register"

        fill_in "Username", with: "Manuela Carmena"
        fill_in "Email", with: "manuela@consul.dev"
        fill_in "Password", with: "invalid_password"
        fill_in "Confirm password", with: "invalid_password"
        check "user_terms_of_service"

        click_button "Register"

        expect(page).to have_content "must contain at least one digit, must contain at least one" \
                                     " upper-case letter"
      end
    end
  end
end
