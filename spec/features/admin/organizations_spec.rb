require 'rails_helper'

feature 'Admin::Organizations' do


  background do
    administrator = create(:user)
    create(:administrator, user: administrator)

    login_as(administrator)
  end

  scenario "pending organizations have links to verify and reject" do
    organization = create(:organization)

    visit admin_organizations_path
    expect(page).to have_link('Verify')
    expect(page).to have_link('Reject')

    click_on 'Verify'
    expect(current_path).to eq(admin_organizations_path)
    expect(page).to have_content ('Verified')

    expect(organization.reload.verified?).to eq(true)
  end

  scenario "verified organizations have link to reject" do
    organization = create(:verified_organization)

    visit admin_organizations_path
    expect(page).to have_content ('Verified')
    expect(page).to_not have_link('Verify')
    expect(page).to have_link('Reject')

    click_on 'Reject'
    expect(current_path).to eq(admin_organizations_path)
    expect(page).to have_content ('Rejected')

    expect(organization.reload.rejected?).to eq(true)
  end

  scenario "rejected organizations have link to verify" do
    organization = create(:rejected_organization)

    visit admin_organizations_path
    expect(page).to have_link('Verify')
    expect(page).to_not have_link('Reject', exact: true)

    click_on 'Verify'
    expect(current_path).to eq(admin_organizations_path)
    expect(page).to have_content ('Verified')

    expect(organization.reload.verified?).to eq(true)
  end

  scenario "Current filter is properly highlighted" do
    visit admin_organizations_path
    expect(page).to_not have_link('All')
    expect(page).to have_link('Pending')
    expect(page).to have_link('Verified')
    expect(page).to have_link('Rejected')

    visit admin_organizations_path(filter: 'all')
    expect(page).to_not have_link('All')
    expect(page).to have_link('Pending')
    expect(page).to have_link('Verified')
    expect(page).to have_link('Rejected')

    visit admin_organizations_path(filter: 'pending')
    expect(page).to have_link('All')
    expect(page).to_not have_link('Pending')
    expect(page).to have_link('Verified')
    expect(page).to have_link('Rejected')

    visit admin_organizations_path(filter: 'verified')
    expect(page).to have_link('All')
    expect(page).to have_link('Pending')
    expect(page).to_not have_link('Verified')
    expect(page).to have_link('Rejected')

    visit admin_organizations_path(filter: 'rejected')
    expect(page).to have_link('All')
    expect(page).to have_link('Pending')
    expect(page).to have_link('Verified')
    expect(page).to_not have_link('Rejected')
  end

  scenario "Filtering organizations" do
    create(:organization, name: "Pending Organization")
    create(:rejected_organization, name: "Rejected Organization")
    create(:verified_organization, name: "Verified Organization")

    visit admin_organizations_path(filter: 'all')
    expect(page).to have_content('Pending Organization')
    expect(page).to have_content('Rejected Organization')
    expect(page).to have_content('Verified Organization')

    visit admin_organizations_path(filter: 'pending')
    expect(page).to have_content('Pending Organization')
    expect(page).to_not have_content('Rejected Organization')
    expect(page).to_not have_content('Verified Organization')

    visit admin_organizations_path(filter: 'verified')
    expect(page).to_not have_content('Pending Organization')
    expect(page).to_not have_content('Rejected Organization')
    expect(page).to have_content('Verified Organization')

    visit admin_organizations_path(filter: 'rejected')
    expect(page).to_not have_content('Pending Organization')
    expect(page).to have_content('Rejected Organization')
    expect(page).to_not have_content('Verified Organization')
  end

  scenario "Verifying organization links remember the pagination setting and the filter" do
    30.times { create(:organization) }

    visit admin_organizations_path(filter: 'pending', page: 2)

    click_on('Verify', match: :first)

    uri = URI.parse(current_url)
    query_params = Rack::Utils.parse_nested_query(uri.query).symbolize_keys

    expect(query_params[:filter]).to eq('pending')
    expect(query_params[:page]).to eq('2')
  end

end
