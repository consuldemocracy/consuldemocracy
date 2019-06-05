require "rails_helper"

feature "Account" do

  background do
    @user = create(:user, username: "Manuela Colau")
    login_as(@user)
  end

  scenario "Show" do
    visit root_path

    click_link "My account"

    expect(page).to have_current_path(account_path, ignore_query: true)

    expect(page).to have_selector("input[value='Manuela Colau']")
    expect(page).to have_selector(avatar("Manuela Colau"), count: 1)
  end

  scenario "Show organization" do
    create(:organization, user: @user, name: "Manuela Corp")

    visit account_path

    expect(page).to have_selector("input[value='Manuela Corp']")
    expect(page).not_to have_selector("input[value='Manuela Colau']")

    expect(page).to have_selector(avatar("Manuela Corp"), count: 1)
  end

  scenario "Edit" do
    visit account_path

    fill_in "account_username", with: "Larry Bird"
    check "account_email_on_comment"
    check "account_email_on_comment_reply"
    uncheck "account_email_digest"
    uncheck "account_email_on_direct_message"
    click_button "Save changes"

    expect(page).to have_content "Changes saved"

    visit account_path

    expect(page).to have_selector("input[value='Larry Bird']")
    expect(find("#account_email_on_comment")).to be_checked
    expect(find("#account_email_on_comment_reply")).to be_checked
    expect(find("#account_email_digest")).not_to be_checked
    expect(find("#account_email_on_direct_message")).not_to be_checked
  end

  scenario "Edit email address" do
    visit account_path

    click_link "Change my credentials"
    fill_in "user_email", with: "new_user_email@example.com"
    fill_in "user_password", with: "new_password"
    fill_in "user_password_confirmation", with: "new_password"
    fill_in "user_current_password", with: "judgmentday"

    click_button "Update"

    notice = "Your account has been updated successfully;"\
             " however, we need to verify your new email address."\
             " Please check your email and click on the link to"\
             " complete the confirmation of your new email address."
    expect(page).to have_content notice

    email = open_last_email
    visit_in_email("Confirm my account")

    logout
    visit root_path
    click_link "Sign in"
    fill_in "user_login", with: "new_user_email@example.com"
    fill_in "user_password", with: "new_password"
    click_button "Enter"

    expect(page).to have_content "You have been signed in successfully."

    visit account_path
    click_link "Change my credentials"
    expect(page).to have_selector("input[value='new_user_email@example.com']")
  end

  scenario "Edit Organization" do
    create(:organization, user: @user, name: "Manuela Corp")
    visit account_path

    fill_in "account_organization_attributes_name", with: "Google"
    check "account_email_on_comment"
    check "account_email_on_comment_reply"

    click_button "Save changes"

    expect(page).to have_content "Changes saved"

    visit account_path

    expect(page).to have_selector("input[value='Google']")
    expect(find("#account_email_on_comment")).to be_checked
    expect(find("#account_email_on_comment_reply")).to be_checked
  end

  context "Option to display badge for official position" do

    scenario "Users with official position of level 1" do
      official_user = create(:user, official_level: 1)

      login_as(official_user)
      visit account_path

      check "account_official_position_badge"
      click_button "Save changes"
      expect(page).to have_content "Changes saved"

      visit account_path
      expect(find("#account_official_position_badge")).to be_checked
    end

    scenario "Users with official position of level 2 and above" do
      official_user2 = create(:user, official_level: 2)
      official_user3 = create(:user, official_level: 3)

      login_as(official_user2)
      visit account_path

      expect(page).not_to have_css "#account_official_position_badge"

      login_as(official_user3)
      visit account_path

      expect(page).not_to have_css "#account_official_position_badge"
    end

  end

  scenario "Errors on edit" do
    visit account_path

    fill_in "account_username", with: ""
    click_button "Save changes"

    expect(page).to have_content error_message
  end

  scenario "Errors editing credentials" do
    visit root_path

    click_link "My account"

    expect(page).to have_current_path(account_path, ignore_query: true)

    expect(page).to have_link("Change my credentials")
    click_link "Change my credentials"
    click_button "Update"

    expect(page).to have_content error_message
  end

  scenario "Erasing account" do
    visit account_path

    click_link "Erase my account"

    fill_in "user_erase_reason", with: "a test"

    click_button "Erase my account"

    expect(page).to have_content "Goodbye! Your account has been cancelled. We hope to see you again soon."

    login_through_form_as(@user)

    expect(page).to have_content "Invalid login or password"
  end

  context "Recommendations" do

    background do
      Setting["feature.user.recommendations"] = true
      Setting["feature.user.recommendations_on_debates"] = true
      Setting["feature.user.recommendations_on_proposals"] = true
    end

    after do
      Setting["feature.user.recommendations"] = nil
      Setting["feature.user.recommendations_on_debates"] = nil
      Setting["feature.user.recommendations_on_proposals"] = nil
    end

    scenario "are enabled by default" do
      visit account_path

      expect(page).to have_content("Recommendations")
      expect(page).to have_content("Show debates recommendations")
      expect(page).to have_content("Show proposals recommendations")
      expect(find("#account_recommended_debates")).to be_checked
      expect(find("#account_recommended_proposals")).to be_checked
    end

    scenario "can be disabled through 'My account' page" do
      visit account_path

      expect(page).to have_content("Recommendations")
      expect(page).to have_content("Show debates recommendations")
      expect(page).to have_content("Show proposals recommendations")
      expect(find("#account_recommended_debates")).to be_checked
      expect(find("#account_recommended_proposals")).to be_checked

      uncheck "account_recommended_debates"
      uncheck "account_recommended_proposals"

      click_button "Save changes"

      expect(find("#account_recommended_debates")).not_to be_checked
      expect(find("#account_recommended_proposals")).not_to be_checked

      @user.reload

      expect(@user.recommended_debates).to be(false)
      expect(@user.recommended_proposals).to be(false)
    end

  end
end
