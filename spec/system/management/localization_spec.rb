require "rails_helper"

describe "Localization" do
  scenario "Wrong locale" do
    login_as_manager
    visit management_root_path(locale: :es)
    visit management_root_path(locale: :klingon)

    expect(page).to have_text("Gestión")
  end

  scenario "Available locales appear in the locale switcher" do
    login_as_manager

    expect(page).to have_select "Language:", with_options: %w[Español English]
  end

  scenario "The current locale is selected" do
    login_as_manager
    expect(page).to have_select "Language:", selected: "English"
    expect(page).to have_text("Management")
  end

  scenario "Changing the locale" do
    login_as_manager
    select "Español", from: "Language:"

    expect(page).not_to have_select "Language:"
    expect(page).to have_select "Idioma:", selected: "Español"
  end

  scenario "Locale switcher not present if only one locale" do
    allow(I18n).to receive(:available_locales).and_return([:en])

    login_as_manager
    expect(page).not_to have_content("Language")
    expect(page).not_to have_css("div.locale")
  end
end
