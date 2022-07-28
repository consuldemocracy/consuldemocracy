require "rails_helper"

describe "Level two verification" do
  scenario "Verification with residency" do
    create(:geozone)
    user = create(:user)
    login_as(user)

    visit account_path
    click_link "Verify my account"

    verify_residence
  end

  context "In Spanish, with no fallbacks" do
    before { allow(I18n.fallbacks).to receive(:[]).and_return([:es]) }

    scenario "Works normally" do
      user = create(:user)
      login_as(user)

      visit verification_path(locale: :es)

      select "DNI", from: "residence_document_type"
      fill_in "residence_document_number", with: "12345678Z"
      select_date "31-#{I18n.l(Date.current.at_end_of_year, format: "%B")}-1980",
                  from: "residence_date_of_birth"

      fill_in "residence_postal_code", with: "28013"
      check "residence_terms_of_service"

      click_button "new_residence_submit"
      expect(page).to have_content "Tu cuenta ya está verificada"
    end
  end
end
