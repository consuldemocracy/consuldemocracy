require 'rails_helper'

feature 'Localization' do

  scenario 'Wrong locale' do
    Globalize.with_locale(:es) do
      create(:widget_card, title: 'Bienvenido a CONSUL',
                           description: 'Software libre para la participación ciudadana.',
                           link_text: 'Más información',
                           link_url: 'http://consulproject.org/',
                           header: true)
    end

    visit root_path(locale: :es)
    visit root_path(locale: :klingon)

    expect(page).to have_text('Bienvenido a CONSUL')
  end

  scenario 'Available locales appear in the locale switcher' do
    visit '/'

    within('.locale-form .js-location-changer') do
      expect(page).to have_content 'Español'
      expect(page).to have_content 'English'
    end
  end

  scenario 'The current locale is selected' do
    visit '/'
    expect(page).to have_select('locale-switcher', selected: 'English')
  end

  scenario 'Changing the locale', :js do
    visit '/'
    expect(page).to have_content('Language')

    select('Español', from: 'locale-switcher')
    expect(page).to have_content('Idioma')
    expect(page).not_to have_content('Language')
    expect(page).to have_select('locale-switcher', selected: 'Español')
  end

  scenario 'Locale switcher not present if only one locale' do
    allow(I18n).to receive(:available_locales).and_return([:en])

    visit '/'
    expect(page).not_to have_content('Language')
    expect(page).not_to have_css('div.locale')
  end
end
