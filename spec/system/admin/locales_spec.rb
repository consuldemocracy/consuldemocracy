require "rails_helper"

describe "Locales management", :admin do
  scenario "Navigate to languages page and update them" do
    allow(I18n).to receive(:available_locales).and_return(%i[de en es fr])
    Setting["locales.default"] = "en"
    Setting["locales.enabled"] = "en de"

    visit admin_root_path

    within ".locale" do
      expect(page).to have_css "[aria-current]", exact_text: "English"

      expect(page).to have_link "English"
      expect(page).to have_link "Deutsch"
      expect(page).not_to have_link "Français"
      expect(page).not_to have_link "Español"
    end

    within "#admin_menu" do
      expect(page).not_to have_link "Languages"

      click_button "Settings"
      click_link "Languages"

      expect(page).to have_css "[aria-current]", exact_text: "Languages"
      expect(page).to have_link "Languages"
    end

    within_fieldset "Default language" do
      expect(page).to have_checked_field "English"

      choose "Español"
    end

    within_fieldset "Enabled languages" do
      uncheck "English"
      check "Français"
    end

    click_button "Save changes"

    expect(page).to have_content "Languages updated successfully"

    within ".locale" do
      expect(page).to have_css "[aria-current]", exact_text: "Español"

      expect(page).to have_link "Français"
      expect(page).to have_link "Español"
      expect(page).to have_link "Deutsch"
      expect(page).not_to have_link "English"
    end
  end

  scenario "select all/none" do
    allow_any_instance_of(Admin::Locales::FormComponent).to receive(:many_available_locales?).and_return(true)

    visit admin_locales_path

    within_fieldset "Enabled languages" do
      expect(page).to have_field type: :checkbox

      click_button "Select all"

      expect(all(:checkbox)).to all(be_checked)

      click_button "Select none"

      all(:checkbox).each { |checkbox| expect(checkbox).not_to be_checked }
    end
  end
end
