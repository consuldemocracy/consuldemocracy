require 'rails_helper'

feature 'Admin dashboard actions' do
  let(:admin) { create :administrator }

  before do
    login_as(admin.user)
  end

  context 'when visiting index' do
    context 'and no actions defined' do
      before do
        visit admin_dashboard_actions_path
      end

      scenario 'shows that there are no records available' do
        expect(page).to have_content('No records found')
      end
    end

    context 'and actions defined' do
      let!(:action) { create :dashboard_action }

      before do
        visit admin_dashboard_actions_path
      end

      scenario 'shows the action data' do
        expect(page).to have_content(action.title)
      end
    end
  end

  context 'when creating an action' do
    let(:action) { build :dashboard_action }

    before do
      visit admin_dashboard_actions_path
      click_link 'Create'
    end

    scenario 'Creates a new action' do
      fill_in 'dashboard_action_title', with: action.title
      fill_in 'dashboard_action_description', with: action.description

      click_button 'Save'

      expect(page).to have_content(action.title)
    end
  end

  context 'when editing an action' do
    let!(:action) { create :dashboard_action }
    let(:title) { Faker::Lorem.sentence }

    before do
      visit admin_dashboard_actions_path
      click_link 'Edit'
    end

    scenario 'Updates the action' do
      fill_in 'dashboard_action_title', with: title
      click_button 'Save'

      expect(page).to have_content(title)
    end
  end

  context 'when destroying an action' do
    let!(:action) { create :dashboard_action }

    before do
      visit admin_dashboard_actions_path
    end

    scenario 'deletes the action', js: true do
      page.accept_confirm do
        click_link 'Delete'
      end

      expect(page).not_to have_content(action.title)
    end
  end
end
