require "rails_helper"

describe "Admin debates", :admin do
  it_behaves_like "flaggable", :debate, admin: true

  scenario "Index" do
    create(:debate, title: "Best beaches")

    visit admin_root_path
    within("#side_menu") { click_link "Debates" }

    expect(page).to have_content "Best beaches"
  end

  scenario "Show debate" do
    debate = create(:debate)
    visit admin_debate_path(debate)

    expect(page).to have_content(debate.title)
    expect(page).to have_content(debate.description)
  end
end
