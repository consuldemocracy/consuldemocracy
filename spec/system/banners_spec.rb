require "rails_helper"

describe "Banner" do
  scenario "Only renders banners in the right section" do
    create(:banner,
           web_sections: [WebSection.find_by!(name: "homepage")],
           description: "Banner description",
           post_started_at: (Time.current - 4.days),
           post_ended_at:   (Time.current + 10.days))

    visit root_path

    within(".banner") { expect(page).to have_content("Banner description") }

    visit debates_path

    expect(page).not_to have_content("Banner description")
  end
end
