require 'rails_helper'

feature "Welcome screen" do

  let(:budget) { create(:budget) }

  scenario 'a regular users sees it the first time he logs in' do
    user = create(:user)

    login_through_form_as(user)

    expect(page).to have_current_path(welcome_path)
  end

  scenario 'Header on welcome page shows correct content' do
    budget.update_attributes(phase: :accepting)

    visit root_path
    expect(page).to have_content("Decide the citizen projects that Madrid City Council")
    expect(page).to have_link("Send your project")

    budget.update_attributes(phase: :reviewing)

    visit root_path
    expect(page).to have_content("100 million euros")
    expect(page).to have_link("See projects")

    budget.update_attributes(phase: :selecting)

    visit root_path
    expect(page).to have_content("Support citizen projects")
    expect(page).to have_link("See projects")

    budget.update_attributes(phase: :valuating)

    visit root_path
    expect(page).to have_content("Most supported projects")
    expect(page).to have_link("See projects")

    budget.update_attributes(phase: :publishing_prices)

    visit root_path
    expect(page).to have_content("Most supported projects")
    expect(page).to have_link("See projects")

    budget.update_attributes(phase: :balloting)

    visit root_path
    expect(page).to have_content("Vote in participatory budgets")
    expect(page).to have_link("See projects")

    budget.update_attributes(phase: :reviewing_ballots)

    visit root_path
    expect(page).to have_content("In a few days we will know the winning projects")
    expect(page).to have_link("See projects")

    budget.update_attributes(phase: :finished)

    visit root_path
    expect(page).to have_content("Thank you for voting!")
    expect(page).to have_link("See projects")
  end

  scenario 'a regular user does not see it when coing to /email' do

    plain, encrypted = Devise.token_generator.generate(User, :email_verification_token)

    user = create(:user, email_verification_token: plain)

    visit email_path(email_verification_token: encrypted)

    fill_in 'user_login', with: user.email
    fill_in 'user_password', with: user.password

    click_button 'Enter'

    expect(page).to have_content("You are a verified user")

    expect(page).to have_current_path(account_path)
  end

  scenario 'it is not shown more than once' do
    user = create(:user, sign_in_count: 2)

    login_through_form_as(user)

    expect(page).to have_current_path(root_path)
  end

  scenario 'is not shown to organizations' do
    organization = create(:organization)

    login_through_form_as(organization.user)

    expect(page).to have_current_path(root_path)
  end

  scenario 'it is not shown to level-2 users' do
    user = create(:user, residence_verified_at: Time.current, confirmed_phone: "123")

    login_through_form_as(user)

    expect(page).to have_current_path(root_path)
  end

  scenario 'it is not shown to level-3 users' do
    user = create(:user, verified_at: Time.current)

    login_through_form_as(user)

    expect(page).to have_current_path(root_path)
  end

  scenario 'is not shown to administrators' do
    administrator = create(:administrator)

    login_through_form_as(administrator.user)

    expect(page).to have_current_path(root_path)
  end

end
