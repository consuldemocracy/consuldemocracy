require 'rails_helper'

feature 'Verification path' do

  scenario "User is verified" do
    user = create(:user, verified_at: Time.now)

    login_as(user)
    visit verification_path

    expect(current_path).to eq account_path
    expect(page).to have_content 'You are a verified user!'
  end

  scenario "User requested a letter" do
    user = create(:user, confirmed_phone: "623456789", residence_verified_at: Time.now,
                         letter_requested_at: Time.now, letter_verification_code: "666")

    login_as(user)
    visit verification_path

    expect(current_path).to eq edit_letter_path
  end

  scenario "User is level two verified" do
    user = create(:user, residence_verified_at: Time.now, confirmed_phone: "666666666")

    login_as(user)
    visit verification_path

    expect(current_path).to eq new_letter_path
  end

  scenario "User received a verification sms" do
    user = create(:user, residence_verified_at: Time.now, unconfirmed_phone: "666666666", sms_confirmation_code: "666")

    login_as(user)
    visit verification_path

    expect(current_path).to eq edit_sms_path
  end

  scenario "User received verification email" do
    user = create(:user, letter_requested_at: Time.now, letter_verification_code: "666")

    login_as(user)
    visit verification_path

    verification_redirect = current_path

    visit verified_user_path

    expect(current_path).to eq verification_redirect
  end

  scenario "User has verified residence" do
    user = create(:user, residence_verified_at: Time.now)

    login_as(user)
    visit verification_path

    verification_redirect = current_path

    visit verified_user_path

    expect(current_path).to eq verification_redirect
  end

  scenario "User has not started verification process" do
    user = create(:user)

    login_as(user)
    visit verification_path

    expect(current_path).to eq new_residence_path
  end
end