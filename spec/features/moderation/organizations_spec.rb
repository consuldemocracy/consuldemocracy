require 'rails_helper'

feature 'Moderations::Organizations' do


  background do
    moderator = create(:user)
    create(:moderator, user: moderator)

    login_as(moderator)
  end

  scenario "pending organizations have links to verify and reject" do
    organization = create(:organization)

    visit moderation_organizations_path
    expect(page).to have_selector(:link_or_button, 'Verify')
    expect(page).to have_selector(:link_or_button, 'Reject')

    click_on 'Verify'
    expect(current_path).to eq(moderation_organizations_path)
    expect(page).to have_content ('Verified')

    expect(organization.reload.verified_organization?).to eq(true)
  end

  scenario "verified organizations have link to reject" do
    organization = create(:organization, organization_verified_at: Time.now)

    visit moderation_organizations_path
    expect(page).to have_content ('Verified')
    expect(page).to_not have_selector(:link_or_button, 'Verify')
    expect(page).to have_selector(:link_or_button, 'Reject')

    click_on 'Reject'
    expect(current_path).to eq(moderation_organizations_path)
    expect(page).to have_content ('Rejected')

    expect(organization.reload.rejected_organization?).to eq(true)
  end

  scenario "rejected organizations have link to verify" do
    organization = create(:organization, organization_rejected_at: Time.now)

    visit moderation_organizations_path
    expect(page).to have_content ('Rejected')
    expect(page).to have_selector(:link_or_button, 'Verify')
    expect(page).to_not have_selector(:link_or_button, 'Reject')

    click_on 'Verify'
    expect(current_path).to eq(moderation_organizations_path)
    expect(page).to have_content ('Verified')

    expect(organization.reload.verified_organization?).to eq(true)
  end

end
