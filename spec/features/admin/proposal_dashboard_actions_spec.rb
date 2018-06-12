require 'rails_helper'

feature 'Admin proposal dasboard actions' do
  let(:admin) { create :administrator }

  before do
    login_as(admin.user)
  end

  context 'when visiting index' do
    context 'and no actions defined' do
      before do
        visit admin_proposal_dashboard_actions_path
      end

      it 'shows that there are no records available' do
        expect(page).to have_content('No records found')
      end
    end

    context 'and actions defined' do
      let!(:action) { create :proposal_dashboard_action }

      before do
        visit admin_proposal_dashboard_actions_path
      end

      it 'shows the action data' do
        expect(page).to have_content(action.title)
      end
    end
  end

  context 'when creating an action' do
    let(:action) { build :proposal_dashboard_action }

    before do
      visit admin_proposal_dashboard_actions_path
      click_link 'Create'
    end

    it 'Creates a new action' do
      fill_in 'proposal_dashboard_action_title', with: action.title
      fill_in 'proposal_dashboard_action_description', with: action.description

      click_button 'Save'

      expect(page).to have_content(action.title)
    end
  end

  context 'when editing an action' do
    let!(:action) { create :proposal_dashboard_action }
    let(:title) { Faker::Lorem.sentence }

    before do
      visit admin_proposal_dashboard_actions_path
      click_link 'Edit'
    end

    it 'Updates the action' do
      fill_in 'proposal_dashboard_action_title', with: title
      click_button 'Save'

      expect(page).to have_content(title)
    end
  end

  context 'when destroying an action' do
    let!(:action) { create :proposal_dashboard_action }

    before do
      visit admin_proposal_dashboard_actions_path
    end

    it 'deletes the action', js: true do
      page.accept_confirm do
        click_link 'Delete'
      end

      expect(page).not_to have_content(action.title)
    end
  end
end
