require 'rails_helper'

feature "Home" do

  feature "For not logged users" do
    scenario 'Welcome message' do
      visit root_path

      expect(page).to have_content "we open this digital Puerta del Sol"
    end
  end

  feature "For signed in users" do
    scenario 'Redirect to proposals' do
      login_as(create(:user))
      visit root_path

      expect(current_path).to eq proposals_path
    end
  end

end
