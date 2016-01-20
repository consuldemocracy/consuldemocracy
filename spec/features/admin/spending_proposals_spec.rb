require 'rails_helper'

feature 'Admin spending proposals' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario 'Disabled with a feature flag' do
    Setting['feature.spending_proposals'] = nil
    expect{ visit admin_spending_proposals_path }.to raise_exception(FeatureFlags::FeatureDisabled)
  end

  scenario 'Index shows spending proposals' do
    spending_proposal = create(:spending_proposal)
    visit admin_spending_proposals_path

    expect(page).to have_content(spending_proposal.title)
  end

  scenario 'Accept from index' do
    spending_proposal = create(:spending_proposal)
    visit admin_spending_proposals_path

    click_link 'Accept'

    expect(page).to_not have_content(spending_proposal.title)

    click_link 'Accepted'
    expect(page).to have_content(spending_proposal.title)

    expect(spending_proposal.reload).to be_accepted
  end

  scenario 'Reject from index' do
    spending_proposal = create(:spending_proposal)
    visit admin_spending_proposals_path

    click_link 'Reject'

    expect(page).to_not have_content(spending_proposal.title)

    click_link('Rejected')
    expect(page).to have_content(spending_proposal.title)

    expect(spending_proposal.reload).to be_rejected
  end

  scenario "Current filter is properly highlighted" do
    visit admin_spending_proposals_path
    expect(page).to_not have_link('Unresolved')
    expect(page).to have_link('Accepted')
    expect(page).to have_link('Rejected')

    visit admin_spending_proposals_path(filter: 'unresolved')
    expect(page).to_not have_link('Unresolved')
    expect(page).to have_link('Accepted')
    expect(page).to have_link('Rejected')

    visit admin_spending_proposals_path(filter: 'accepted')
    expect(page).to have_link('Unresolved')
    expect(page).to_not have_link('Accepted')
    expect(page).to have_link('Rejected')

    visit admin_spending_proposals_path(filter: 'rejected')
    expect(page).to have_link('Accepted')
    expect(page).to have_link('Unresolved')
    expect(page).to_not have_link('Rejected')
  end

  scenario "Filtering proposals" do
    create(:spending_proposal, title: "Recent spending proposal")
    create(:spending_proposal, title: "Good spending proposal", resolution: "accepted")
    create(:spending_proposal, title: "Bad spending proposal", resolution: "rejected")

    visit admin_spending_proposals_path(filter: 'unresolved')
    expect(page).to have_content('Recent spending proposal')
    expect(page).to_not have_content('Good spending proposal')
    expect(page).to_not have_content('Bad spending proposal')

    visit admin_spending_proposals_path(filter: 'accepted')
    expect(page).to have_content('Good spending proposal')
    expect(page).to_not have_content('Recent spending proposal')
    expect(page).to_not have_content('Bad spending proposal')

    visit admin_spending_proposals_path(filter: 'rejected')
    expect(page).to have_content('Bad spending proposal')
    expect(page).to_not have_content('Good spending proposal')
    expect(page).to_not have_content('Recent spending proposal')
  end

  scenario "Action links remember the pagination setting and the filter" do
    per_page = Kaminari.config.default_per_page
    (per_page + 2).times { create(:spending_proposal, resolution: "accepted") }

    visit admin_spending_proposals_path(filter: 'accepted', page: 2)

    click_on('Reject', match: :first, exact: true)

    expect(current_url).to include('filter=accepted')
    expect(current_url).to include('page=2')
  end

  scenario 'Show' do
    spending_proposal = create(:spending_proposal, geozone: create(:geozone))
    visit admin_spending_proposals_path

    click_link spending_proposal.title

    expect(page).to have_content(spending_proposal.title)
    expect(page).to have_content(spending_proposal.description)
    expect(page).to have_content(spending_proposal.author.name)
    expect(page).to have_content(spending_proposal.geozone.name)
  end

  scenario 'Accept from show' do
    spending_proposal = create(:spending_proposal)
    visit admin_spending_proposal_path(spending_proposal)

    click_link 'Accept'

    expect(page).to_not have_content(spending_proposal.title)

    click_link 'Accepted'
    expect(page).to have_content(spending_proposal.title)

    expect(spending_proposal.reload).to be_accepted
  end

  scenario 'Reject from show' do
    spending_proposal = create(:spending_proposal)
    visit admin_spending_proposal_path(spending_proposal)

    click_link 'Reject'

    expect(page).to_not have_content(spending_proposal.title)

    click_link('Rejected')
    expect(page).to have_content(spending_proposal.title)

    expect(spending_proposal.reload).to be_rejected
  end

end
