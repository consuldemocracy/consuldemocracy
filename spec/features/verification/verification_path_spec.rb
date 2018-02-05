require 'rails_helper'

describe 'Verification path' do

  it "User is an organization" do
    user = create(:user, verified_at: Time.current)
    create(:organization, user: user)

    login_as(user)
    visit verification_path

    expect(page).to have_current_path(account_path)
  end

  it "User is verified" do
    user = create(:user, verified_at: Time.current)

    login_as(user)
    visit verification_path

    expect(page).to have_current_path(account_path)
    expect(page).to have_content 'Your account is already verified'
  end

  it "User requested a letter" do
    user = create(:user, confirmed_phone: "623456789", residence_verified_at: Time.current,
                         letter_requested_at: Time.current, letter_verification_code: "666")

    login_as(user)
    visit verification_path

    expect(page).to have_current_path(edit_letter_path)
  end

  it "User is level two verified" do
    user = create(:user, residence_verified_at: Time.current, confirmed_phone: "666666666")

    login_as(user)
    visit verification_path

    expect(page).to have_current_path(new_letter_path)
  end

  it "User received a verification sms" do
    user = create(:user, residence_verified_at: Time.current, unconfirmed_phone: "666666666", sms_confirmation_code: "666")

    login_as(user)
    visit verification_path

    expect(page).to have_current_path(edit_sms_path)
  end

  it "User received verification email" do
    user = create(:user, residence_verified_at: Time.current, email_verification_token: "1234")

    login_as(user)
    visit verification_path

    verification_redirect = current_path

    visit verified_user_path

    expect(page).to have_current_path(verification_redirect)
  end

  it "User has verified residence" do
    user = create(:user, residence_verified_at: Time.current)

    login_as(user)
    visit verification_path

    verification_redirect = current_path

    visit verified_user_path

    expect(page).to have_current_path(verification_redirect)
  end

  it "User has not started verification process" do
    user = create(:user)

    login_as(user)
    visit verification_path

    expect(page).to have_current_path(new_residence_path)
  end

  it "A verified user can not access verification pages" do
    user = create(:user, verified_at: Time.current)

    login_as(user)

    verification_paths = [new_residence_path, verified_user_path, edit_sms_path, new_letter_path]
    verification_paths.each do |step_path|
      visit step_path

      expect(page).to have_current_path(account_path)
      expect(page).to have_content 'Your account is already verified'
    end
  end

end
