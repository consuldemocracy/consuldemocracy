require 'rails_helper'

feature 'Representatives' do

  scenario "Select a representative" do
    forum1 = create(:forum)
    forum2 = create(:forum)
    user = create(:user, :level_two)
    login_as(user)

    visit forums_path

    click_link forum1.name
    click_button "Delegar"

    expect(page).to have_content "You have updated your representative"
    expect(page).to have_css("#forum_#{forum1.id}.active")
  end

end