require 'rails_helper'

feature 'Localization' do

  scenario 'Wrong locale' do
    visit root_path(locale: :es)
    visit root_path(locale: :klingon)

    expect(page).to have_text('Estamos abriendo Madrid')
  end

  scenario 'Changing locale' do
    visit root_path(locale: :es)
    locale_switcher = find('#locale-switcher')

    expect(page).to have_text('Estamos abriendo Madrid')
    expect(locale_switcher).to have_text('en')
    expect(locale_switcher).to_not have_text('es')

    find('#locale-link-en').click
    locale_switcher = find('#locale-switcher')

    expect(page).to have_text('We are opening Madrid')
    expect(locale_switcher).to have_text('es')
    expect(locale_switcher).to_not have_text('en')
  end
end
