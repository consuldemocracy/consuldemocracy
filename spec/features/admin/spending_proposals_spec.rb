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

  scenario 'Show' do
    administrator = create(:administrator, user: create(:user, username: 'Ana', email: 'ana@admins.org'))
    valuator = create(:valuator, user: create(:user, username: 'Rachel', email: 'rachel@valuators.org'))
    spending_proposal = create(:spending_proposal,
                                geozone: create(:geozone),
                                association_name: 'People of the neighbourhood',
                                price: 1234.56,
                                feasible: false,
                                feasible_explanation: 'It is impossible',
                                administrator: administrator)
    spending_proposal.valuators << valuator

    visit admin_spending_proposals_path

    click_link spending_proposal.title

    expect(page).to have_content(spending_proposal.title)
    expect(page).to have_content(spending_proposal.description)
    expect(page).to have_content(spending_proposal.author.name)
    expect(page).to have_content(spending_proposal.association_name)
    expect(page).to have_content(spending_proposal.geozone.name)
    expect(page).to have_content('1234.56')
    expect(page).to have_content('Not feasible')
    expect(page).to have_content('It is impossible')
    expect(page).to have_select('spending_proposal[administrator_id]', selected: 'Ana (ana@admins.org)')

    within('#assigned_valuators') do
      expect(page).to have_content('Rachel (rachel@valuators.org)')
    end
  end

  scenario 'Administrator assigment', :js do
    spending_proposal = create(:spending_proposal)

    administrator = create(:administrator, user: create(:user, username: 'Ana', email: 'ana@admins.org'))

    visit admin_spending_proposal_path(spending_proposal)

    expect(page).to have_select('spending_proposal[administrator_id]', selected: 'Undefined')
    select 'Ana (ana@admins.org)', from: 'spending_proposal[administrator_id]'

    visit admin_spending_proposal_path(spending_proposal)

    expect(page).to have_select('spending_proposal[administrator_id]', selected: 'Ana (ana@admins.org)')
  end

  scenario 'Valuators assigments', :js do
    spending_proposal = create(:spending_proposal)

    valuator1 = create(:valuator, user: create(:user, username: 'Valentina', email: 'v1@valuators.org'))
    valuator2 = create(:valuator, user: create(:user, username: 'Valerian', email: 'v2@valuators.org'))
    valuator3 = create(:valuator, user: create(:user, username: 'Val', email: 'v3@valuators.org'))

    visit admin_spending_proposal_path(spending_proposal)

    within('#assigned_valuators') do
      expect(page).to have_content('Undefined')
      expect(page).to_not have_content('Valentina (v1@valuators.org)')
      expect(page).to_not have_content('Valerian (v2@valuators.org)')
      expect(page).to_not have_content('Val (v3@valuators.org)')
    end

    visit admin_spending_proposal_path(spending_proposal)

    click_link "Assign valuators"

    within('#valuators-assign-list') do
      check "valuator_ids_#{valuator1.id}"
      check "valuator_ids_#{valuator3.id}"
    end

    within('#assigned_valuators') do
      expect(page).to have_content('Valentina (v1@valuators.org)')
      expect(page).to have_content('Val (v3@valuators.org)')
      expect(page).to_not have_content('Undefined')
      expect(page).to_not have_content('Valerian (v2@valuators.org)')
    end

    visit admin_spending_proposal_path(spending_proposal)

    within('#assigned_valuators') do
      expect(page).to have_content('Valentina (v1@valuators.org)')
      expect(page).to have_content('Val (v3@valuators.org)')
      expect(page).to_not have_content('Undefined')
      expect(page).to_not have_content('Valerian (v2@valuators.org)')
    end
  end

end
