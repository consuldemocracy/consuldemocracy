require "rails_helper"

describe "Localization" do
  before do
    login_as_manager
  end

  scenario "Wrong locale" do
    visit management_root_path(locale: :es)
    visit management_root_path(locale: :klingon)

    expect(page).to have_text("Gestión")
  end

  scenario "Available locales appear in the locale switcher" do
    visit management_root_path

    within(".locale-form .js-location-changer") do
      expect(page).to have_content "Castellano"
      expect(page).to have_content "English"
    end
  end

  scenario "The current locale is selected" do
    visit management_root_path
    expect(page).to have_select("locale-switcher", selected: "English")
    expect(page).to have_text("Management")
  end

  scenario "Changing the locale", :js do
    visit management_root_path
    expect(page).to have_content("Language")

    select("Castellano", from: "locale-switcher")
    expect(page).to have_content("Idioma")
    expect(page).not_to have_content("Language")
    expect(page).to have_select("locale-switcher", selected: "Castellano")
  end

  scenario "Locale switcher not present if only one locale" do
    allow(I18n).to receive(:available_locales).and_return([:en])

    visit management_root_path
    expect(page).not_to have_content("Language")
    expect(page).not_to have_css("div.locale")
  end
end
