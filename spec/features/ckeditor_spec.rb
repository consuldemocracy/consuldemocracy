require 'rails_helper'

feature 'CKEditor' do

  scenario 'is present before & after turbolinks update page', :js do
    author = create(:user)
    login_as(author)

    visit new_debate_path

    expect(page).to have_css "#cke_debate_description"

    click_link 'Debates'
    click_link 'Start a debate'

    expect(page).to have_css "#cke_debate_description"
  end

  scenario 'is present before & after turbolinks update page2', :js do
    author = create(:user)
    login_as(author)

    visit new_medida_path

    expect(page).to have_css "#cke_medida_description"

    click_link 'Medidas'
    click_link 'Start a medida'

    expect(page).to have_css "#cke_medida_description"
  end
end
