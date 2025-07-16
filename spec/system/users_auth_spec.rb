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
        click_link "Sign out"

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

        click_link "Sign up with Twitter"

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

        click_link "Sign up with Twitter"

        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content "To continue, please click on the confirmation " \
                                     "link that we have sent you via email"

        confirm_email
        expect(page).to have_content "Your account has been confirmed"

        visit "/"
        click_link "Sign in"
        click_link "Sign in with Twitter"
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
        click_link "Sign up with Twitter"

        expect(page).to have_current_path(finish_signup_path)
        fill_in "Email", with: "manueladelascarmenas@example.com"
        click_button "Register"

        expect(page).to have_content "To continue, please click on the confirmation " \
                                     "link that we have sent you via email"

        confirm_email
        expect(page).to have_content "Your account has been confirmed"

        visit "/"
        click_link "Sign in"
        click_link "Sign in with Twitter"
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
        click_link "Sign up with Twitter"

        expect(page).to have_current_path(finish_signup_path)
        click_link "Cancel login"

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
        click_link "Sign in with Twitter"

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
        click_link "Sign up with Twitter"

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
        click_link "Sign up with Twitter"

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
        click_link "Sign in with Twitter"

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
        click_link "Sign up with Twitter"

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
        click_link "Sign in with Twitter"
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
        click_link "Sign up with Twitter"

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
        click_link "Sign in with Twitter"
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
        click_link "Sign in with Google"

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

        click_link "Sign up with Wordpress"

        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content "To continue, please click on the confirmation " \
                                     "link that we have sent you via email"

        confirm_email
        expect(page).to have_content "Your account has been confirmed"

        visit "/"
        click_link "Sign in"
        click_link "Sign in with Wordpress"
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
        click_link "Sign up with Wordpress"

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
        click_link "Sign in with Wordpress"

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
        click_link "Sign up with SAML"

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
        click_link "Sign up with SAML"

        expect(page).to have_content "To continue, please click on the confirmation " \
                                     "link that we have sent you via email"

        confirm_email
        expect(page).to have_content "Your account has been confirmed"
        expect(page).to have_current_path new_user_session_path

        click_link "Sign in with SAML"

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
        click_link "Sign in with SAML"

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
        click_link "Sign in with SAML"

        expect(page).to have_content "Successfully identified as Saml"
        expect_to_be_signed_in

        within("#notice") { click_button "Close" }
        click_link "My account"

        expect(page).to have_field "Username", with: "tester"

        click_link "Change my login details"

        expect(page).to have_field "Email", with: "tester@consul.dev"

        click_on "Go back"
        
        click_link "Sign out"
      end

      scenario "Different SAML authentication configurations for different tenants", :seed_tenants do
        # Create tenants
        create(:tenant, schema: "mars")
        create(:tenant, schema: "venus")

        # Enable SAML login for both tenants
        Tenant.switch("mars") { Setting["feature.saml_login"] = true }
        Tenant.switch("venus") { Setting["feature.saml_login"] = true }

        # Mock different SAML secrets for each tenant
        mars_secrets = {
          saml_sp_entity_id: "https://mars.consul.dev/saml/metadata",
          saml_idp_metadata_url: "https://mars-idp.example.com/metadata",
          saml_idp_sso_service_url: "https://mars-idp.example.com/sso"
        }

        venus_secrets = {
          saml_sp_entity_id: "https://venus.consul.dev/saml/metadata",
          saml_idp_metadata_url: "https://venus-idp.example.com/metadata",
          saml_idp_sso_service_url: "https://venus-idp.example.com/sso"
        }

        # Mock authentication responses from different IdPs
        mars_saml_hash = {
          provider: "saml",
          uid: "mars-user-123",
          info: {
            name: "Mars User",
            email: "mars.user@mars.gov",
            verified: "1"
          },
          extra: {
            raw_info: {
              issuer: "https://mars-idp.example.com"
            }
          }
        }

        venus_saml_hash = {
          provider: "saml",
          uid: "venus-user-456",
          info: {
            name: "Venus User",
            email: "venus.user@venus.gov",
            verified: "1"
          },
          extra: {
            raw_info: {
              issuer: "https://venus-idp.example.com"
            }
          }
        }

        # Test Mars tenant authentication
        with_subdomain("mars") do
          Tenant.switch("mars") do
           
            expect_any_instance_of(OmniauthTenantSetup).to receive(:secrets).and_return(mars_secrets)

            allow_any_instance_of(OneLogin::RubySaml::IdpMetadataParser).to receive(:parse_remote_to_hash).and_return({})

            expect(mars_saml_hash[:extra][:raw_info][:issuer]).to eq("https://mars-idp.example.com")


            OmniAuth.config.add_mock(:saml, mars_saml_hash)

            visit new_user_registration_path
            click_link "Sign up with SAML"

            expect(page).to have_content "Successfully identified as Saml"
            expect_to_be_signed_in

            within("#notice") { click_button "Close" }
            click_link "My account"

            expect(page).to have_field "Username", with: "Mars User"

            click_link "Change my login details"
            expect(page).to have_field "Email", with: "mars.user@mars.gov"

          end
        end

        with_subdomain("venus") do
          Tenant.switch("venus") do

            expect_any_instance_of(OmniauthTenantSetup).to receive(:secrets).and_return(mars_secrets)

            allow_any_instance_of(OneLogin::RubySaml::IdpMetadataParser).to receive(:parse_remote_to_hash).and_return({})

            expect(venus_saml_hash[:extra][:raw_info][:issuer]).to eq("https://venus-idp.example.com")

            OmniAuth.config.add_mock(:saml, venus_saml_hash)

            visit new_user_registration_path
            click_link "Sign up with SAML"

            expect(page).to have_content "Successfully identified as Saml"
            expect_to_be_signed_in

            within("#notice") { click_button "Close" }
            click_link "My account"

            expect(page).to have_field "Username", with: "Venus User"

            click_link "Change my login details"
            expect(page).to have_field "Email", with: "venus.user@venus.gov"

          end
        end
      end

      scenario "SAML user from one tenant cannot sign in to another tenant", :seed_tenants do
        create(:tenant, schema: "mars")
        create(:tenant, schema: "venus")
  
        # Enable SAML for both tenants
        Tenant.switch("mars") { Setting["feature.saml_login"] = true }
        Tenant.switch("venus") { Setting["feature.saml_login"] = true }
  
        # Create a user in Mars tenant with SAML identity
        mars_user = nil
        Tenant.switch("mars") do
          mars_user = create(:user, username: "marsuser", email: "mars@consul.dev", password: "My123456")
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
  
        # User can sign in to Mars tenant
        with_subdomain("mars") do
          OmniAuth.config.add_mock(:saml, mars_saml_hash)
    
          visit new_user_session_path
          click_link "Sign in with SAML"
    
          expect(page).to have_content "Successfully identified as Saml"
          expect_to_be_signed_in
    
          within("#notice") { click_button "Close" }

          click_link "My account"
    
          expect(page).to have_field "Username", with: "marsuser"
    
          click_link "Change my login details"
    
          expect(page).to have_field "Email", with: "mars@consul.dev"

        end
  
        # Same user cannot sign in to Venus tenant (will create new account)
        with_subdomain("venus") do
          OmniAuth.config.add_mock(:saml, mars_saml_hash)
    
          visit new_user_registration_path
          click_link "Sign up with SAML"

          expect(page).to have_content "To continue, please click on the confirmation " \
                                     "link that we have sent you via email"

          confirm_email
          expect(page).to have_content "Your account has been confirmed"
          expect(page).to have_current_path new_user_session_path

          click_link "Sign in with SAML"
          # This should create a new user in Venus tenant, not sign in the Mars user
          expect(page).to have_content "Successfully identified as Saml"
          expect_to_be_signed_in
    
          within("#notice") { click_button "Close" }
          click_link "My account"
    
          expect(page).to have_field "Username", with: "marsuser"
          expect(page).to have_css "html.tenant-venus"
    
        end
  
        # Verify that two separate users were created
        mars_user_count = nil
        venus_user_count = nil
  
        Tenant.switch("mars") do
          mars_user_count = User.where(email: "mars@consul.dev").count
        end
  
        Tenant.switch("venus") do
          venus_user_count = User.where(email: "mars@consul.dev").count
        end
  
        expect(mars_user_count).to eq(1)
        expect(venus_user_count).to eq(1)
      end

      scenario "Different SAML secrets are applied for different tenants" do
        create(:tenant, schema: "mars")
        create(:tenant, schema: "venus")

        stub_secrets(
          saml_sp_entity_id: "https://default.consul.dev/saml/metadata",
          saml_idp_metadata_url: "https://default-idp.example.com/metadata",
          saml_idp_sso_service_url: "https://default-idp.example.com/sso",
          tenants: {
            mars: {
              saml_sp_entity_id: "https://mars.consul.dev/saml/metadata",
              saml_idp_metadata_url: "https://mars-idp.example.com/metadata",
              saml_idp_sso_service_url: "https://mars-idp.example.com/sso"
            },
            venus: {
              saml_sp_entity_id: "https://venus.consul.dev/saml/metadata",
              saml_idp_metadata_url: "https://venus-idp.example.com/metadata",
              saml_idp_sso_service_url: "https://venus-idp.example.com/sso"
            }
          }
        )

        with_subdomain("mars") do
          Tenant.switch("mars") do
            # Mock environment for Mars
            mars_strategy_options = {}
            mars_strategy = double("mars_strategy", options: mars_strategy_options)
            mars_env = {
              "omniauth.strategy" => mars_strategy,
              "HTTP_HOST" => "mars.consul.dev"
            }

            # Apply SAML configuration for Mars
            OmniauthTenantSetup.saml(mars_env)
        
            # Verify Mars-specific configuration
            expect(mars_strategy_options[:sp_entity_id]).to eq("https://mars.consul.dev/saml/metadata")
            expect(mars_strategy_options[:idp_metadata_url]).to eq("https://mars-idp.example.com/metadata")
            expect(mars_strategy_options[:idp_sso_service_url]).to eq("https://mars-idp.example.com/sso")
          end
        end

        with_subdomain("venus") do
          Tenant.switch("venus") do
            # Mock environment for Venus
            venus_strategy_options = {}
            venus_strategy = double("venus_strategy", options: venus_strategy_options)
            venus_env = {
              "omniauth.strategy" => venus_strategy,
              "HTTP_HOST" => "venus.consul.dev"
            }

            # Apply SAML configuration for Venus
            OmniauthTenantSetup.saml(venus_env)

            # Verify Venus-specific configuration
            expect(venus_strategy_options[:sp_entity_id]).to eq("https://venus.consul.dev/saml/metadata")
            expect(venus_strategy_options[:idp_metadata_url]).to eq("https://venus-idp.example.com/metadata")
            expect(venus_strategy_options[:idp_sso_service_url]).to eq("https://venus-idp.example.com/sso")
          end
        end
      end

      scenario "Tenant overwriting SAML secrets" do
        stub_secrets(
          saml_sp_entity_id: "https://default.consul.dev/saml/metadata",
          saml_idp_metadata_url: "https://default-idp.example.com/metadata",
          saml_idp_sso_service_url: "https://default-idp.example.com/sso",
          tenants: {
            mars: {
              saml_sp_entity_id: "https://mars.consul.dev/saml/metadata",
              saml_idp_metadata_url: "https://mars-idp.example.com/metadata",
              saml_idp_sso_service_url: "https://mars-idp.example.com/sso"
            },
            venus: {
              saml_sp_entity_id: "https://venus.consul.dev/saml/metadata",
              saml_idp_metadata_url: "https://venus-idp.example.com/metadata",
              saml_idp_sso_service_url: "https://venus-idp.example.com/sso"
            }
          }
        )

        # Test default tenant
        allow(Tenant).to receive(:current_schema).and_return("public")
        secrets = Tenant.current_secrets
        expect(secrets.saml_sp_entity_id).to eq "https://default.consul.dev/saml/metadata"
        expect(secrets.saml_idp_metadata_url).to eq "https://default-idp.example.com/metadata"
        expect(secrets.saml_idp_sso_service_url).to eq "https://default-idp.example.com/sso"

        # Test Mars tenant with overrides
        create(:tenant, schema: "mars")
        allow(Tenant).to receive(:current_schema).and_return("mars")
        secrets = Tenant.current_secrets
        expect(secrets.saml_sp_entity_id).to eq "https://mars.consul.dev/saml/metadata"
        expect(secrets.saml_idp_metadata_url).to eq "https://mars-idp.example.com/metadata"
        expect(secrets.saml_idp_sso_service_url).to eq "https://mars-idp.example.com/sso"

        # Test Venus tenant with overrides
        create(:tenant, schema: "venus")
        allow(Tenant).to receive(:current_schema).and_return("venus")
        secrets = Tenant.current_secrets
        expect(secrets.saml_sp_entity_id).to eq "https://venus.consul.dev/saml/metadata"
        expect(secrets.saml_idp_metadata_url).to eq "https://venus-idp.example.com/metadata"
        expect(secrets.saml_idp_sso_service_url).to eq "https://venus-idp.example.com/sso"

        # Test Earth tenant without overrides (should use defaults)
        create(:tenant, schema: "earth")
        allow(Tenant).to receive(:current_schema).and_return("earth")
        secrets = Tenant.current_secrets
        expect(secrets.saml_sp_entity_id).to eq "https://default.consul.dev/saml/metadata"
        expect(secrets.saml_idp_metadata_url).to eq "https://default-idp.example.com/metadata"
        expect(secrets.saml_idp_sso_service_url).to eq "https://default-idp.example.com/sso"
      end

      scenario "SAML configuration setup with default secrets for non-overridden tenant" do
        stub_secrets(
          saml_sp_entity_id: "https://default.consul.dev/saml/metadata",
          saml_idp_metadata_url: "https://default-idp.example.com/metadata",
          saml_idp_sso_service_url: "https://default-idp.example.com/sso"
        )

        create(:tenant, schema: "earth")

        with_subdomain("earth") do
          Tenant.switch("earth") do
            # Mock environment for Earth
            earth_strategy_options = {}
            earth_strategy = double("earth_strategy", options: earth_strategy_options)
            earth_env = {
              "omniauth.strategy" => earth_strategy,
              "HTTP_HOST" => "earth.consul.dev"
            }

            # Apply SAML configuration for Earth
            OmniauthTenantSetup.saml(earth_env)

            # Verify Earth uses default configuration
            expect(earth_strategy_options[:sp_entity_id]).to eq("https://default.consul.dev/saml/metadata")
            expect(earth_strategy_options[:idp_metadata_url]).to eq("https://default-idp.example.com/metadata")
            expect(earth_strategy_options[:idp_sso_service_url]).to eq("https://default-idp.example.com/sso")
          end
        end
      end
    end
  end

  scenario "Sign out" do
    user = create(:user)
    login_as(user)

    visit "/"
    click_link "Sign out"

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
