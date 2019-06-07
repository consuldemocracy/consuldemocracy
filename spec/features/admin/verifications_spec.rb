require "rails_helper"

feature "Incomplete verifications" do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

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
    verified_user = create(:user, :level_two, username: "Juan Carlos")
    unverified_user = create(:user, :incomplete_verification, username: "Juan_anonymous")
    unverified_user = create(:user, :incomplete_verification, username: "Isabel_anonymous")

    visit admin_verifications_path

    fill_in "name_or_email", with: "juan"
    click_button "Search"

    expect(page).to have_content("Juan_anonymous")
    expect(page).not_to have_content("Juan Carlos")
    expect(page).not_to have_content("Isabel_anonymous")
  end

  scenario "Residence unverified" do
    incompletely_verified_user = create(:user, :incomplete_verification)

    visit admin_verifications_path

    within "#user_#{incompletely_verified_user.id}" do
      expect(page).to have_content "DNI"
      expect(page).to have_content incompletely_verified_user.document_number
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
