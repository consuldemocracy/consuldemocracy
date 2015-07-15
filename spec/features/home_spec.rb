require 'rails_helper'

feature "Home" do

  scenario "Welcome message" do
    visit '/'
    expect(page).to have_content 'Bienvenido al Ayuntamiento de Madrid'
  end

end
