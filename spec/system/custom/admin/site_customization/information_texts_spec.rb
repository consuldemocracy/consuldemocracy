require "rails_helper"

describe "Admin custom information texts", :admin do
  scenario "page is correctly loaded" do
    visit admin_site_customization_information_texts_path

    click_link "Basic customization"
    expect(page).to have_content "Help with debates"
    expect(page).to have_content "Help with proposals"
    expect(page).to have_content "Help with voting"
    expect(page).to have_content "Help with collaborative legislation"

    within("#information-texts-tabs") { click_link "Debates" }

    expect(page).to have_content "Edit debate"

    within("#information-texts-tabs") { click_link "Budgets" }

    expect(page).to have_content "Your ballot"

    within("#information-texts-tabs") { click_link "Community" }
    expect(page).to have_content "Access the community"

    within("#information-texts-tabs") { click_link "Proposals" }
    expect(page).to have_content "Create proposal"

    within "#information-texts-tabs" do
      click_link "Polls"
    end

    expect(page).to have_content "Results"

    within("#information-texts-tabs") { click_link "Collaborative legislation" }

    expect(page).to have_content "Help with collaborative legislation"

    within("#information-texts-tabs") { click_link "Budgets" }

    expect(page).to have_content "You have not voted any investment project."

    click_link "Layouts"
    expect(page).to have_content "Accessibility"

    click_link "Emails"
    expect(page).to have_content "Confirm your email"

    within "#information-texts-tabs" do
      click_link "Management"
    end

    expect(page).to have_content "This user account is already verified."

    click_link "Welcome"
    expect(page).to have_content "See all debates"
  end
end
