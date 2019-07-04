require "rails_helper"

feature "Sessions" do

  scenario "Staying in the same page after doing login/logout" do
    user = create(:user, sign_in_count: 10)
    debate = create(:debate)

    visit debate_path(debate)

    login_through_form_as(user)

    expect(page).to have_content("You have been signed in successfully")
    expect(page).to have_current_path(debate_path(debate))

    click_link "Sign out"

    expect(page).to have_content("You have been signed out successfully")
    expect(page).to have_current_path(debate_path(debate))
  end

end

