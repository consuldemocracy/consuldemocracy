require "rails_helper"

describe "Localization" do
  scenario "Wrong locale" do
    login_as create(:manager).user
    visit management_root_path(locale: :es)
    visit management_root_path(locale: :klingon)

    expect(page).to have_text("Gestión")
  end

  scenario "Changing the locale" do
    login_as_manager
    select "Español", from: "Language:"

    expect(page).not_to have_select "Language:"
    expect(page).to have_select "Idioma:", selected: "Español"
    expect(page).to have_content "Gestión"
  end
end
