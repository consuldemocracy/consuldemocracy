require "rails_helper"

describe "Localization" do
  scenario "Wrong locale" do
    I18n.with_locale(:es) do
      create(:widget_card, title: "Bienvenido a CONSUL",
                           description: "Software libre para la participación ciudadana.",
                           link_text: "Más información",
                           link_url: "http://consuldemocracy.org/",
                           header: true)
    end

    visit root_path(locale: :es)
    visit root_path(locale: :klingon)

    expect(page).to have_text("Bienvenido a CONSUL")
  end

  scenario "Changing the locale" do
    visit "/"
    select "Español", from: "Language:"

    expect(page).not_to have_select "Language:"
    expect(page).to have_select "Idioma:", selected: "Español"
  end

  scenario "Keeps query parameters while using protected redirects" do
    visit "/debates?order=created_at&host=evil.dev"

    select "Español", from: "Language:"

    expect(current_host).to eq "http://127.0.0.1"
    expect(page).to have_current_path "/debates?locale=es&order=created_at"
  end

  context "Only one locale" do
    before do
      allow(I18n).to receive(:available_locales).and_return([:en])
      I18n.reload!
    end

    after { I18n.reload! }

    scenario "Locale switcher not present" do
      visit "/"
      expect(page).not_to have_content("Language")
      expect(page).not_to have_css("div.locale")
      expect(page).not_to have_css(".top-links")
    end
  end

  context "Missing language names" do
    let!(:default_enforce) { I18n.enforce_available_locales }
    let!(:default_locales) { I18n.available_locales.dup }

    before do
      I18n.enforce_available_locales = false
      I18n.available_locales = default_locales + [:wl]
      I18n.locale = :wl
    end

    after do
      I18n.enforce_available_locales = default_enforce
      I18n.available_locales = default_locales
      I18n.locale = I18n.default_locale
    end

    scenario "Available locales without language translation display locale key" do
      visit "/"

      within(".locale-form .js-location-changer") do
        expect(page).to have_content "wl"
      end
    end
  end

  scenario "uses default locale when session locale has disappeared" do
    default_locales = I18n.available_locales

    visit root_path(locale: :es)

    expect(page).to have_content "Entrar"

    begin
      I18n.available_locales = default_locales - [:es]

      visit root_path

      expect(page).to have_content "Sign in"
    ensure
      I18n.available_locales = default_locales
    end
  end
end
