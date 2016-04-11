require 'rails_helper'

feature 'Open Plenary' do

  scenario "Create a debate" do
    author = create(:user)
    login_as(author)

    visit root_path
    first(:link, "Open processes").click
    click_link "Send a proposal or question"
    click_link "Make a question"

    fill_in_debate
    click_button 'Start a debate'

    expect(page).to have_content 'Debate created successfully.'

    within("#tags") do
      expect(page).to have_content "plenoabierto"
    end
  end

  scenario "Create a proposal" do
    author = create(:user)
    login_as(author)

    visit root_path
    first(:link, "Open processes").click
    click_link "Send a proposal or question"
    click_link "Send a proposal"

    fill_in_proposal
    click_button 'Create proposal'

    expect(page).to have_content 'Proposal created successfully.'

    within("#tags") do
      expect(page).to have_content "plenoabierto"
    end
  end

end