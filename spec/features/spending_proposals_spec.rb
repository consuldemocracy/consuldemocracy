require 'rails_helper'

feature 'Spending proposals' do

  let(:author) { create(:user, :level_two) }

  scenario 'Index' do
    visit spending_proposals_path

    expect(page).to_not have_link('Create investment proposal', href: new_spending_proposal_path)
    expect(page).to have_link('verify your account')

    login_as(author)

    visit spending_proposals_path

    expect(page).to have_link('Create investment proposal', href: new_spending_proposal_path)
    expect(page).to_not have_link('verify your account')
  end

  scenario 'Create' do
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

    expect(page).to have_content 'Investment proposal created successfully'
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

    expect(page).to_not have_content 'Investment proposal created successfully'
    expect(page).to have_content '1 error'

    fill_in 'spending_proposal_captcha', with: correct_captcha_text
    click_button 'Create'

    expect(page).to have_content 'Investment proposal created successfully'
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

  scenario "Show (as valuator)" do
    user = create(:user)
    admin = create(:valuator, user: user)
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

    expect(page).to_not have_content(spending_proposal.title)
    expect(page).to have_content("You do not have permission to access this page")
  end

end
