require 'rails_helper'

feature "Home" do

  scenario "Welcome message" do
    visit '/'
    expect(page).to have_content 'Debates sobre Madrid'
  end

end
