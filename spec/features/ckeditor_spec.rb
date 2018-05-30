require 'rails_helper'

feature 'CKEditor' do

  scenario 'is present before & after turbolinks update page', :js do
    author = create(:user)
    login_as(author)

    visit new_debate_path

    expect(page).to have_css ".ckeditor-container"

    click_link 'Debates'
    click_link 'Start a debate'

    expect(page).to have_css ".ckeditor-container"
  end

end