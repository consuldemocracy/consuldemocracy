require 'rails_helper'

feature 'Representatives' do

  scenario "Select a representative" do
    forum1 = create(:forum)
    forum2 = create(:forum)
    user = create(:user, :level_two)
    login_as(user)

    visit new_representative_path

    select forum1.name, from: 'user_representative_id'
    click_button "Save"
    expect(page).to have_content "You have updated your representative"

    visit root_path
    visit new_representative_path
    expect(page).to have_select('user_representative_id', selected: "#{forum1.name}")
  end

end