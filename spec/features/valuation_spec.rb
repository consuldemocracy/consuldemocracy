require 'rails_helper'

feature 'Valuation' do
  let(:user) { create(:user) }

  background do
    Setting['feature.spending_proposals'] = true
    Setting['feature.spending_proposal_features.voting_allowed'] = true
  end

  after do
    Setting['feature.spending_proposals'] = nil
    Setting['feature.spending_proposal_features.voting_allowed'] = nil
  end

  scenario 'Access as regular user is not authorized' do
    login_as(user)
    visit root_path

    expect(page).to_not have_link("Valuation")
    visit valuation_root_path

    expect(current_path).not_to eq(valuation_root_path)
    expect(current_path).to eq(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario 'Access as moderator is not authorized' do
    create(:moderator, user: user)
    login_as(user)
    visit root_path

    expect(page).to_not have_link("Valuation")
    visit valuation_root_path

    expect(current_path).not_to eq(valuation_root_path)
    expect(current_path).to eq(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario 'Access as manager is not authorized' do
    create(:manager, user: user)
    login_as(user)
    visit root_path

    expect(page).to_not have_link("Valuation")
    visit valuation_root_path

    expect(current_path).not_to eq(valuation_root_path)
    expect(current_path).to eq(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario 'Access as poll officer is not authorized' do
    create(:poll_officer, user: user)
    login_as(user)
    visit root_path

    expect(page).to_not have_link("Valuation")
    visit valuation_root_path

    expect(current_path).not_to eq(valuation_root_path)
    expect(current_path).to eq(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario 'Access as a valuator is authorized' do
    create(:valuator, user: user)
    login_as(user)
    visit root_path

    expect(page).to have_link("Valuation")
    click_on "Valuation"

    expect(current_path).to eq(valuation_root_path)
    expect(page).to_not have_content "You do not have permission to access this page"
  end

  scenario 'Access as an administrator is authorized' do
    create(:administrator, user: user)
    login_as(user)
    visit root_path

    expect(page).to have_link("Valuation")
    click_on "Valuation"

    expect(current_path).to eq(valuation_root_path)
    expect(page).to_not have_content "You do not have permission to access this page"
  end

  scenario "Valuation access links" do
    create(:valuator, user: user)
    login_as(user)
    visit root_path

    expect(page).to have_link('Valuation')
    expect(page).to_not have_link('Administration')
    expect(page).to_not have_link('Moderation')
  end

  scenario 'Valuation dashboard' do
    create(:valuator, user: user)
    login_as(user)
    visit root_path

    click_link 'Valuation'

    expect(current_path).to eq(valuation_root_path)
    expect(page).to have_css('#valuation_menu')
    expect(page).to_not have_css('#admin_menu')
    expect(page).to_not have_css('#moderation_menu')
  end

end
