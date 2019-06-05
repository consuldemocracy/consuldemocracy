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
  end

  def login_through_form_with_email_and_password(email="manuela@consul.dev", password="judgementday")
    visit root_path
    click_link "Sign in"

    fill_in "user_login", with: email
    fill_in "user_password", with: password

    click_button "Enter"
  end

  def login_through_form_as(user)
    visit root_path
    click_link "Sign in"

    fill_in "user_login", with: user.email
    fill_in "user_password", with: user.password

    click_button "Enter"
  end

  def login_through_form_as_officer(user)
    visit root_path
    click_link "Sign in"

    fill_in "user_login", with: user.email
    fill_in "user_password", with: user.password

    click_button "Enter"
    visit new_officing_residence_path
  end

  def login_as_manager
    manager = create(:manager)
    login_as(manager.user)
    visit management_sign_in_path
  end

  def login_managed_user(user)
    allow_any_instance_of(Management::BaseController).to receive(:managed_user).and_return(user)
  end

  def confirm_email
    body = ActionMailer::Base.deliveries.last.try(:body)
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
  end

  def expect_to_be_signed_in
    expect(find(".top-bar-right")).to have_content "My account"
  end

  def expect_not_to_be_signed_in
    expect(find(".top-bar-right")).not_to have_content "My account"
  end
end
