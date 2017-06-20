require 'rails_helper'

feature 'Localization' do

  background do
    login_as_manager
  end

  scenario 'Wrong locale' do
    visit management_root_path(locale: :es)
    visit management_root_path(locale: :klingon)

    expect(page).to have_text('Gestión')
  end

  scenario 'Available locales appear in the locale switcher' do
    visit management_root_path

    within('.locale-form .js-location-changer') do
      expect(page).to have_content 'Español'
      expect(page).to have_content 'English'
    end
  end

  scenario 'The current locale is selected' do
    visit management_root_path
    expect(page).to have_select('locale-switcher', selected: 'English')
    expect(page).to have_text('Management')
  end

  # Se elimina esta opción
  scenario 'Changing the locale', :js do
    skip
    visit management_root_path
    expect(page).to have_content('Language')

    select('Español', from: 'locale-switcher')
    expect(page).to have_content('Idioma')
    expect(page).to_not have_content('Language')
    expect(page).to have_select('locale-switcher', selected: 'Español')
  end

  scenario 'Locale switcher not present if only one locale' do
    expect(I18n).to receive(:available_locales).and_return([:en])

    visit management_root_path
    expect(page).to_not have_content('Language')
    expect(page).to_not have_css('div.locale')
  end
end
