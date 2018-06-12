require 'rails_helper'

feature "Home" do

  feature "For not logged users" do

    xscenario 'Welcome message' do
      visit root_path

      expect(page).to have_content "Love the city, and it will become a city you love"
    end

  end

end
