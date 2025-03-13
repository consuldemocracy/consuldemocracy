require "rails_helper"

describe "DocumentVerifications" do
  scenario "Verifying a level 3 user shows an 'already verified' page" do
    user = create(:user, :level_three)

    login_as_manager
    visit management_document_verifications_path
    fill_in "document_verification_document_number", with: user.document_number
    click_button "Check document"

    expect(page).to have_content "already verified"
  end

  scenario "Verifying a level 2 user displays the verification form" do
    user = create(:user, :level_two)

    login_as_manager
    visit management_document_verifications_path
    fill_in "document_verification_document_number", with: user.document_number
    click_button "Check document"

    expect(page).to have_content "Vote for budget projects"

    click_button "Verify"

    expect(page).to have_content "already verified"

    visit management_document_verifications_path
    fill_in "document_verification_document_number", with: user.document_number
    click_button "Check document"

    expect(page).to have_content "already verified"
  end

  describe "Verifying througth Census" do
    context "Census API" do
      scenario "Verifying a user which does not exist and is not in the census shows an error" do
        expect_any_instance_of(Verification::Management::Document)
          .to receive(:in_census?)
          .and_return(false)

        login_as_manager
        visit management_document_verifications_path
        fill_in "document_verification_document_number", with: "inexisting"
        click_button "Check document"

        expect(page).to have_content "This document is not registered"
      end

      scenario "Verifying a user who exists in the census but not in the db allows sending an email" do
        login_as_manager
        visit management_document_verifications_path
        fill_in "document_verification_document_number", with: "12345678Z"
        click_button "Check document"

        expect(page).to have_content "Please introduce the email used on the account"
      end
    end

    context "Remote Census API", :remote_census do
      scenario "Verifying a user which does not exist and is not in the census shows an error" do
        expect_any_instance_of(Verification::Management::Document)
          .to receive(:in_census?)
          .and_return(false)

        login_as_manager
        visit management_document_verifications_path
        fill_in "document_verification_document_number", with: "12345678Z"
        fill_in "Date of birth", with: Date.new(1980, 12, 31)
        fill_in "document_verification_postal_code", with: "inexisting"
        click_button "Check document"

        expect(page).to have_content "This document is not registered"
      end

      scenario "Verifying a user which does exists in the census but not in the db
                redirects allows sending an email" do
        mock_valid_remote_census_response

        login_as_manager
        visit management_document_verifications_path
        fill_in "document_verification_document_number", with: "12345678Z"
        fill_in "Date of birth", with: Date.new(1980, 12, 31)
        fill_in "document_verification_postal_code", with: "28013"
        click_button "Check document"

        expect(page).to have_content "Please introduce the email used on the account"
      end
    end
  end

  scenario "Document number is format-standarized" do
    login_as_manager
    visit management_document_verifications_path
    fill_in "document_verification_document_number", with: "12345 - h"
    click_button "Check document"

    expect(page).to have_content "Document number: 12345H"
  end

  scenario "User age is checked" do
    expect_any_instance_of(Verification::Management::Document).to receive(:under_age?).and_return(true)

    login_as_manager
    visit management_document_verifications_path
    fill_in "document_verification_document_number", with: "12345678Z"
    click_button "Check document"

    expect(page).to have_content "You don't have the required age to verify your account."
  end
end
