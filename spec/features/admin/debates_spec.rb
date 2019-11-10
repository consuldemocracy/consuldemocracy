require "rails_helper"

describe "Admin debates" do
  before do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario "Show debate" do
    debate = create(:debate)
    visit admin_debate_path(debate)

    expect(page).to have_content(debate.title)
    expect(page).to have_content(debate.description)
  end
end
