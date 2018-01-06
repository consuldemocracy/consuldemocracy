require 'rails_helper'

describe 'Admin proposals' do

  before do
    admin = create(:administrator)
    login_as(admin.user)
  end

  it 'Disabled with a feature flag' do
    Setting['feature.proposals'] = nil
    admin = create(:administrator)
    login_as(admin.user)

    expect{ visit admin_proposals_path }.to raise_exception(FeatureFlags::FeatureDisabled)

    Setting['feature.proposals'] = true
  end

  it 'List shows all relevant info' do
    proposal = create(:proposal, :hidden)
    visit admin_proposals_path

    expect(page).to have_content(proposal.title)
    expect(page).to have_content(proposal.summary)
    expect(page).to have_content(proposal.description)
    expect(page).to have_content(proposal.question)
    expect(page).to have_content(proposal.external_url)
    expect(page).to have_content(proposal.video_url)
  end

  it 'Restore' do
    proposal = create(:proposal, :hidden)
    visit admin_proposals_path

    click_link 'Restore'

    expect(page).to_not have_content(proposal.title)

    expect(proposal.reload).to_not be_hidden
    expect(proposal).to be_ignored_flag
  end

  it 'Confirm hide' do
    proposal = create(:proposal, :hidden)
    visit admin_proposals_path

    click_link 'Confirm'

    expect(page).to_not have_content(proposal.title)
    click_link('Confirmed')
    expect(page).to have_content(proposal.title)

    expect(proposal.reload).to be_confirmed_hide
  end

  it "Current filter is properly highlighted" do
    visit admin_proposals_path
    expect(page).to_not have_link('Pending')
    expect(page).to have_link('All')
    expect(page).to have_link('Confirmed')

    visit admin_proposals_path(filter: 'Pending')
    expect(page).to_not have_link('Pending')
    expect(page).to have_link('All')
    expect(page).to have_link('Confirmed')

    visit admin_proposals_path(filter: 'all')
    expect(page).to have_link('Pending')
    expect(page).to_not have_link('All')
    expect(page).to have_link('Confirmed')

    visit admin_proposals_path(filter: 'with_confirmed_hide')
    expect(page).to have_link('All')
    expect(page).to have_link('Pending')
    expect(page).to_not have_link('Confirmed')
  end

  it "Filtering proposals" do
    create(:proposal, :hidden, title: "Unconfirmed proposal")
    create(:proposal, :hidden, :with_confirmed_hide, title: "Confirmed proposal")

    visit admin_proposals_path(filter: 'pending')
    expect(page).to have_content('Unconfirmed proposal')
    expect(page).to_not have_content('Confirmed proposal')

    visit admin_proposals_path(filter: 'all')
    expect(page).to have_content('Unconfirmed proposal')
    expect(page).to have_content('Confirmed proposal')

    visit admin_proposals_path(filter: 'with_confirmed_hide')
    expect(page).to_not have_content('Unconfirmed proposal')
    expect(page).to have_content('Confirmed proposal')
  end

  it "Action links remember the pagination setting and the filter" do
    per_page = Kaminari.config.default_per_page
    (per_page + 2).times { create(:proposal, :hidden, :with_confirmed_hide) }

    visit admin_proposals_path(filter: 'with_confirmed_hide', page: 2)

    click_on('Restore', match: :first, exact: true)

    expect(current_url).to include('filter=with_confirmed_hide')
    expect(current_url).to include('page=2')
  end

end
