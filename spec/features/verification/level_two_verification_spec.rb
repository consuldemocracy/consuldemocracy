require "rails_helper"

feature "Level two verification" do

  scenario "Verification with residency and sms" do
    create(:geozone)
    user = create(:user)
    login_as(user)

    visit account_path
    click_link "Verify my account"

    verify_residence

    fill_in "sms_phone", with: "611111111"
    click_button "Send"

    expect(page).to have_content "Security code confirmation"

    user = user.reload
    fill_in "sms_confirmation_code", with: user.sms_confirmation_code
    click_button "Send"

    expect(page).to have_content "Code correct"
  end

  context "In Spanish, with no fallbacks" do
    before do
      skip unless I18n.available_locales.include?(:es)
      allow(I18n.fallbacks).to receive(:[]).and_return([:es])
    end

    scenario "Works normally" do
      user = create(:user)
      login_as(user)

      visit verification_path(locale: :es)
      verify_residence
    end
  end

end
