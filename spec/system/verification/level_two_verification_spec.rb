require "rails_helper"

describe "Level two verification" do
  scenario "Verification with residency and sms" do
    allow_any_instance_of(Verification::Sms).to receive(:generate_confirmation_code).and_return("5678")
    create(:geozone)
    user = create(:user)
    login_as(user)

    visit account_path
    click_link "Verify my account"

    verify_residence

    fill_in "sms_phone", with: "611111111"
    click_button "Send"

    expect(page).to have_content "Security code confirmation"

    fill_in "sms_confirmation_code", with: "5678"
    click_button "Send"

    expect(page).to have_content "Code correct"
  end

  context "In Spanish, with no fallbacks" do
    before { allow(I18n.fallbacks).to receive(:[]).and_return([:es]) }

    scenario "Works normally" do
      user = create(:user)
      login_as(user)

      visit verification_path(locale: :es)
      verify_residence
    end
  end
end
