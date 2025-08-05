require "rails_helper"

describe "Admin LLM settings", :admin do
  scenario "Index empty" do
    visit admin_settings_path

    click_link "LLM Settings"

    expect(page).to have_content "LLM Provider"
  end
end
