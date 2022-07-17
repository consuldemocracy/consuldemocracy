require "rails_helper"

describe "Installation details" do
  scenario "Show the current version of CONSUL" do
    visit root_path
    within(".footer") { expect(page).to have_content "1.5.0" }
  end
end
