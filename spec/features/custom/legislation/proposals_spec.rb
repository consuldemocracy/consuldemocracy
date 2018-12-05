require 'rails_helper'

feature 'Legislation Proposals' do

  let(:user)     { create(:user) }
  let(:film_library_process) { create(:legislation_process, film_library: true) }

  scenario "Film library proposal", :js do
    create(:legislation_proposal, process: film_library_process)

    login_as user
    visit new_legislation_process_proposal_path(film_library_process)

    fill_in 'legislation_proposal[title]', with: 'Film name'
    fill_in 'legislation_proposal[summary]', with: 'Summary of the film'
    imageable_attach_new_file(create(:image), Rails.root.join('spec/fixtures/files/clippy.jpg'))
    find(:css, '#legislation_proposal_terms_of_service').set(true)

    click_button 'Create proposal'

    expect(page).to have_content 'Film name'
    expect(page).to have_content 'Summary of the film'
    expect(page).to have_css("img[alt='#{Legislation::Proposal.last.image.title}']")
  end

end
