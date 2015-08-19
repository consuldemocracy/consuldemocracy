require 'rails_helper'

feature 'Locale Switcher' do

  scenario 'Available locales appear in the locale switcher' do
    visit '/'

    within('.js-locale-switcher') do
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
    expect(page).to have_content('Site language')

    select('Español', from: 'locale-switcher')
    expect(page).to have_content('Idioma de la página')
    expect(page).to_not have_content('Site language')
    expect(page).to have_select('locale-switcher', selected: 'Español')
  end

end
