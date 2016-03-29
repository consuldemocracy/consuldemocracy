require 'rails_helper'

feature 'Spending proposals' do

  let(:author) { create(:user, :level_two, username: 'Isabel') }

  scenario 'Index' do
    spending_proposals = [create(:spending_proposal), create(:spending_proposal), create(:spending_proposal)]

    visit spending_proposals_path

    expect(page).to have_selector('#investment-projects .investment-project', count: 3)
    spending_proposals.each do |spending_proposal|
      within('#investment-projects') do
        expect(page).to have_content spending_proposal.title
        expect(page).to have_css("a[href='#{spending_proposal_path(spending_proposal)}']", text: spending_proposal.title)
      end
    end
  end

  scenario 'Create' do
    login_as(author)

    visit spending_proposals_path
    click_link 'Create spending proposal'

    expect(current_path).to eq(page_path('proposal_type'))
    within('#new_spending_proposal_container') do
      click_link 'Create proposal'
    end

    expect(current_path).to eq(new_spending_proposal_path)

    fill_in 'spending_proposal_title', with: 'Build a skyscraper'
    fill_in 'spending_proposal_description', with: 'I want to live in a high tower over the clouds'
    fill_in 'spending_proposal_external_url', with: 'http://http://skyscraperpage.com/'
    fill_in 'spending_proposal_association_name', with: 'People of the neighbourhood'
    fill_in 'spending_proposal_captcha', with: correct_captcha_text
    select  'All city', from: 'spending_proposal_geozone_id'
    check 'spending_proposal_terms_of_service'

    click_button 'Create'

    expect(page).to have_content 'Investment project created successfully'
    expect(page).to have_content('Build a skyscraper')
    expect(page).to have_content('I want to live in a high tower over the clouds')
    expect(page).to have_content('Isabel')
    expect(page).to have_content('People of the neighbourhood')
    expect(page).to have_content('All city')
  end

  scenario 'Create notice' do
    login_as(author)

    visit new_spending_proposal_path
    fill_in 'spending_proposal_title', with: 'Build a skyscraper'
    fill_in 'spending_proposal_description', with: 'I want to live in a high tower over the clouds'
    fill_in 'spending_proposal_external_url', with: 'http://http://skyscraperpage.com/'
    fill_in 'spending_proposal_association_name', with: 'People of the neighbourhood'
    fill_in 'spending_proposal_captcha', with: correct_captcha_text
    select  'All city', from: 'spending_proposal_geozone_id'
    check 'spending_proposal_terms_of_service'

    click_button 'Create'

    expect(page).to have_content 'Investment project created successfully'
    expect(page).to have_content 'You can access it from My activity'

    within "#notice" do
      click_link 'My activity'
    end

    expect(current_url).to eq(user_url(author, filter: :spending_proposals))
    expect(page).to have_content "1 Spending proposal"
    expect(page).to have_content "Build a skyscraper"
  end

  scenario 'Captcha is required for proposal creation' do
    login_as(author)

    visit new_spending_proposal_path
    fill_in 'spending_proposal_title', with: 'Build a skyscraper'
    fill_in 'spending_proposal_description', with: 'I want to live in a high tower over the clouds'
    fill_in 'spending_proposal_external_url', with: 'http://http://skyscraperpage.com/'
    fill_in 'spending_proposal_captcha', with: 'wrongText'
    check 'spending_proposal_terms_of_service'

    click_button 'Create'

    expect(page).to_not have_content 'Investment project created successfully'
    expect(page).to have_content '1 error'

    fill_in 'spending_proposal_captcha', with: correct_captcha_text
    click_button 'Create'

    expect(page).to have_content 'Investment project created successfully'
  end

  scenario 'Errors on create' do
    login_as(author)

    visit new_spending_proposal_path
    click_button 'Create'
    expect(page).to have_content error_message
  end

  scenario "Show (as admin)" do
    user = create(:user)
    admin = create(:administrator, user: user)
    login_as(admin.user)

    spending_proposal = create(:spending_proposal,
                                geozone: create(:geozone),
                                association_name: 'People of the neighbourhood')

    visit spending_proposal_path(spending_proposal)

    expect(page).to have_content(spending_proposal.title)
    expect(page).to have_content(spending_proposal.description)
    expect(page).to have_content(spending_proposal.author.name)
    expect(page).to have_content(spending_proposal.association_name)
    expect(page).to have_content(spending_proposal.geozone.name)
  end

  scenario "Show (as user)" do
    user = create(:user)
    login_as(user)

    spending_proposal = create(:spending_proposal,
                                geozone: create(:geozone),
                                association_name: 'People of the neighbourhood')

    visit spending_proposal_path(spending_proposal)

    expect(page).to have_content(spending_proposal.title)
    expect(page).to have_content(spending_proposal.description)
    expect(page).to have_content(spending_proposal.author.name)
    expect(page).to have_content(spending_proposal.association_name)
    expect(page).to have_content(spending_proposal.geozone.name)
  end

  context "Destroy" do

    scenario "User can destroy owned spending proposals" do
      user = create(:user, :level_two)
      spending_proposal = create(:spending_proposal, author: user)
      login_as(user)

      visit user_path(user)
      within("#spending_proposal_#{spending_proposal.id}") do
        click_link "Delete"
      end

      expect(page).to have_content("Spending proposal deleted succesfully.")

      visit user_path(user)
      expect(page).not_to have_css("spending_proposal_list")
    end

  end

end
