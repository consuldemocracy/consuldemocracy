require 'rails_helper'

feature 'Verify Letter' do

  scenario 'Send letter level 2 verified with phone' do
    user = create(:user, residence_verified_at: Time.now, confirmed_phone: "611111111")

    login_as(user)
    visit new_letter_path

    click_button "Send me a letter"

    expect(page).to have_content "You will receive a letter to your home address"
  end

  scenario "Error accessing address from UserApi" do
    user = create(:user, residence_verified_at: Time.now, confirmed_phone: "611111111")

    login_as(user)
    visit new_letter_path

    allow_any_instance_of(UserApi).to receive(:address).and_return(nil)

    click_button "Send me a letter"

    expect(page).to have_content "We could not verify your address with the Census please try again later"
  end

  scenario 'Send letter level 2 user verified with email' do
    user = create(:user, residence_verified_at: Time.now, confirmed_phone: "611111111")

    login_as(user)
    visit new_letter_path

    click_button "Send me a letter"

    expect(page).to have_content "You will receive a letter to your home address"
  end

  scenario "Deny access unless verified residence" do
    user = create(:user)

    login_as(user)
    visit new_letter_path

    expect(page).to have_content 'You have not yet confirmed your residence'
    expect(URI.parse(current_url).path).to eq(new_residence_path)
  end

  scenario "Deny access unless verified phone/email" do
    user = create(:user, residence_verified_at: Time.now)

    login_as(user)
    visit new_letter_path

    expect(page).to have_content 'You have not yet confirmed your personal data'
    expect(URI.parse(current_url).path).to eq(new_sms_path)
  end

end