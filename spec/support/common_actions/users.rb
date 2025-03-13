module Users
  def sign_up(email = "manuela@consul.dev", password = "judgementday")
    visit "/"

    click_link "Register"

    fill_in "user_username",              with: "Manuela Carmena #{rand(99999)}"
    fill_in "user_email",                 with: email
    fill_in "user_password",              with: password
    fill_in "user_password_confirmation", with: password
    check "user_terms_of_service"

    click_button "Register"
    expect(page).to have_content "Thank you for registering"
  end

  def login_through_form_with(email_or_username, password:)
    visit new_user_session_path

    fill_in "Email or username", with: email_or_username
    fill_in "Password", with: password

    click_button "Enter"
  end

  def login_through_form_as(user)
    login_through_form_with(user.email, password: user.password)
  end

  def login_through_form_as_officer(officer)
    login_through_form_as(officer.user)

    expect(page).to have_content "You have been signed in successfully"
  end

  def login_as_manager(manager = create(:manager))
    login_as(manager.user)
    visit management_sign_in_path

    expect(page).to have_content "Management"
  end

  def login_managed_user(user)
    allow_any_instance_of(Management::BaseController).to receive(:managed_user).and_return(user)
  end

  def confirm_email
    body = ActionMailer::Base.deliveries.last&.body
    expect(body).to be_present

    sent_token = /.*confirmation_token=(.*)".*/.match(body.to_s)[1]
    visit user_confirmation_path(confirmation_token: sent_token)

    expect(page).to have_content "Your account has been confirmed"
  end

  def reset_password
    create(:user, email: "manuela@consul.dev")

    visit "/"
    click_link "Sign in"
    click_link "Forgotten your password?"

    fill_in "user_email", with: "manuela@consul.dev"
    click_button "Send instructions"

    expect(page).to have_content "If your email address is in our database, in a few minutes " \
                                 "you will receive a link to use to reset your password."
  end

  def expect_to_be_signed_in
    expect(find("#responsive_menu")).to have_content "My account"
  end

  def expect_not_to_be_signed_in
    expect(find("#responsive_menu")).not_to have_content "My account"
  end

  def do_login_for(user, management:)
    if management
      login_managed_user(user)
      login_as_manager
    else
      login_as(user)
    end
  end
end
