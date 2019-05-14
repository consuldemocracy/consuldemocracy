require "rails_helper"

describe "DocumentVerifications" do

  before do
    login_as_manager
  end

  scenario "Verifying a level 3 user shows an 'already verified' page" do
    user = create(:user, :level_three)

    visit management_document_verifications_path
    fill_in "document_verification_document_number", with: user.document_number
    click_button "Check document"

    expect(page).to have_content "already verified"
  end

  scenario "Verifying a level 2 user displays the verification form" do

    user = create(:user, :level_two)

    visit management_document_verifications_path
    fill_in "document_verification_document_number", with: user.document_number
    click_button "Check document"

    expect(page).to have_content "Vote proposals"

    click_button "Verify"

    expect(page).to have_content "already verified"

    expect(user.reload).to be_level_three_verified
  end

  describe "Verifying througth Census" do

    context "Census API" do

      scenario "Verifying a user which does not exist and is not in the census shows an error" do

        expect_any_instance_of(Verification::Management::Document).to receive(:in_census?).
                                                                      and_return(false)

        visit management_document_verifications_path
        fill_in "document_verification_document_number", with: "inexisting"
        click_button "Check document"

        expect(page).to have_content "This document is not registered"
      end

      scenario "Verifying a user which does exists in the census but not in the db redirects allows sending an email" do

        visit management_document_verifications_path
        fill_in "document_verification_document_number", with: "12345678Z"
        click_button "Check document"

        expect(page).to have_content "Please introduce the email used on the account"
      end

    end

    context "Remote Census API" do

      before do
        Setting["feature.remote_census"] = true
        Setting["remote_census.request.date_of_birth"] = "some.value"
        Setting["remote_census.request.postal_code"] = "some.value"
        access_user_data = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item"
        access_residence_data = "get_habita_datos_response.get_habita_datos_return.datos_vivienda.item"
        Setting["remote_census.response.date_of_birth"] = "#{access_user_data}.fecha_nacimiento_string"
        Setting["remote_census.response.postal_code"] = "#{access_residence_data}.codigo_postal"
        Setting["remote_census.response.valid"] = access_user_data
      end

      after do
        Setting["feature.remote_census"] = nil
        Setting["remote_census.request.date_of_birth"] = nil
        Setting["remote_census.request.postal_code"] = nil
      end

      scenario "Verifying a user which does not exist and is not in the census shows an error" do

        expect_any_instance_of(Verification::Management::Document).to receive(:in_census?).
                                                                      and_return(false)

        visit management_document_verifications_path
        fill_in "document_verification_document_number", with: "12345678Z"
        select_date "31-December-1980", from: "document_verification_date_of_birth"
        fill_in "document_verification_postal_code", with: "inexisting"
        click_button "Check document"

        expect(page).to have_content "This document is not registered"
      end

      scenario "Verifying a user which does exists in the census but not in the db redirects allows sending an email" do

        visit management_document_verifications_path
        fill_in "document_verification_document_number", with: "12345678Z"
        select_date "31-December-1980", from: "document_verification_date_of_birth"
        fill_in "document_verification_postal_code", with: "28013"
        click_button "Check document"

        expect(page).to have_content "Please introduce the email used on the account"
      end

    end

  end

  scenario "Document number is format-standarized" do

    visit management_document_verifications_path
    fill_in "document_verification_document_number", with: "12345 - h"
    click_button "Check document"

    expect(page).to have_content "Document number: 12345H"
  end

  scenario "User age is checked" do
    expect_any_instance_of(Verification::Management::Document).to receive(:under_age?).and_return(true)

    visit management_document_verifications_path
    fill_in "document_verification_document_number", with: "12345678Z"
    click_button "Check document"

    expect(page).to have_content "You don't have the required age to verify your account."
  end

end
