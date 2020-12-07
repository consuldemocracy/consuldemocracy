require "rails_helper"

describe "Incomplete verifications", :admin do
  scenario "Index" do
    incompletely_verified_user1 = create(:user, :incomplete_verification)
    incompletely_verified_user2 = create(:user, :incomplete_verification)
    never_tried_to_verify_user = create(:user)
    verified_user = create(:user, :level_two)

    visit admin_verifications_path

    expect(page).to have_content(incompletely_verified_user1.username)
    expect(page).to have_content(incompletely_verified_user2.username)
    expect(page).not_to have_content(never_tried_to_verify_user.username)
    expect(page).not_to have_content(verified_user.username)
  end

  scenario "Search" do
    create(:user, :level_two, username: "Juan Carlos")
    create(:user, :incomplete_verification, username: "Juan_anonymous")
    create(:user, :incomplete_verification, username: "Isabel_anonymous")

    visit admin_verifications_path

    fill_in "search", with: "juan"
    click_button "Search"

    expect(page).to have_content("Juan_anonymous")
    expect(page).not_to have_content("Juan Carlos")
    expect(page).not_to have_content("Isabel_anonymous")
  end

  scenario "Residence unverified" do
    incompletely_verified_user = create(:user, :incomplete_verification)
    failed_census_call = incompletely_verified_user.failed_census_calls.first

    visit admin_verifications_path

    within "#user_#{incompletely_verified_user.id}" do
      expect(page).to have_content "DNI"
      expect(page).to have_content failed_census_call.document_number
      expect(page).to have_content Date.new(1900, 1, 1)
      expect(page).to have_content "28000"
    end
  end

  scenario "Phone not given" do
    incompletely_verified_user = create(:user, residence_verified_at: Time.current, unconfirmed_phone: nil)

    visit admin_verifications_path

    within "#user_#{incompletely_verified_user.id}" do
      expect(page).to have_content "Phone not given"
    end
  end

  scenario "SMS code not confirmed" do
    incompletely_verified_user = create(:user, residence_verified_at: Time.current,
                                               unconfirmed_phone:     "611111111",
                                               sms_confirmation_code: "1234",
                                               confirmed_phone:       nil)

    visit admin_verifications_path

    within "#user_#{incompletely_verified_user.id}" do
      expect(page).to have_content "Has not confirmed the sms code"
    end
  end
end
