require "rails_helper"

describe Account::VerifyAccountComponent do
  it "shows a link to verify account to unverified users" do
    account = User.new

    render_inline Account::VerifyAccountComponent.new(account)

    expect(page).to have_content "To perform all the actions verify your account."
    expect(page).to have_link "Verify my account"
  end

  it "shows a link to complete verification to level two verified users" do
    account = User.new(level_two_verified_at: Time.current)

    render_inline Account::VerifyAccountComponent.new(account)

    expect(page).to have_content "To perform all the actions verify your account."
    expect(page).to have_link "Complete verification"
  end

  it "shows information about a verified account to level three verified users" do
    account = User.new(verified_at: Time.current)

    render_inline Account::VerifyAccountComponent.new(account)

    expect(page).not_to have_content "To perform all the actions verify your account."
    expect(page).to have_content "Account verified"
  end

  it "does not show verification info to organizations" do
    account = User.new(organization: Organization.new)

    render_inline Account::VerifyAccountComponent.new(account)

    expect(page).not_to be_rendered
  end
end
