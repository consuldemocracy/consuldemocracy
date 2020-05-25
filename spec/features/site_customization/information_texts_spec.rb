require "rails_helper"

describe "Custom information texts" do

  scenario "Show custom texts instead of default ones" do
    admin = create(:administrator)
    login_as(admin.user)

    debate_key = "debates.index.section_footer.title"
    proposal_key = "proposals.index.section_footer.title"

    visit admin_site_customization_information_texts_path(tab: "debates")
    fill_in "contents[content_#{debate_key}]values[value_en]", with: "Custom help about debates"
    click_button "Save"

    visit admin_site_customization_information_texts_path(tab: "proposals")
    fill_in "contents[content_#{proposal_key}]values[value_en]", with: "Custom help about proposals"
    click_button "Save"

    visit debates_path

    within("#section_help") do
      expect(page).to have_content "Custom help about debates"
      expect(page).not_to have_content "Help about debates"
    end

    visit proposals_path

    within("#section_help") do
      expect(page).to have_content "Custom help about proposals"
      expect(page).not_to have_content "Help about proposals"
    end
  end
end
