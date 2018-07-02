require 'rails_helper'

describe 'Administrator tasks' do
  let(:administrator) { create(:administrator) }

  before do
    login_as administrator.user
  end

  context 'when accessing the pending task list' do
    context 'and no pending task' do
      before do
        visit admin_proposal_dashboard_administrator_tasks_path
      end

      scenario 'informs that there are no pending tasks' do
        expect(page).to have_content('There are no pending tasks')
      end
    end

    context 'and there are pending tasks' do
      let!(:task) { create :administrator_task, :pending }

      before do
        visit admin_proposal_dashboard_administrator_tasks_path
      end

      scenario 'shows the related proposal title' do
        expect(page).to have_content(task.source.proposal.title)
      end

      scenario 'shows the requested action title' do
        expect(page).to have_content(task.source.proposal_dashboard_action.title)
      end

      scenario 'has a link that allows solving the request' do
        expect(page).to have_link('Solve')
      end
    end
  end

  context 'when solving a pending task' do
    let!(:task) { create :administrator_task, :pending }

    before do
      visit admin_proposal_dashboard_administrator_tasks_path
      click_link 'Solve'
    end

    scenario 'contains a link to the proposal' do
      expect(page).to have_link('Check the proposal details')
    end

    scenario 'contains a button that solves the request' do
      expect(page).to have_button('Mark as solved')
    end

    context 'and the Mark as solved button is pressed' do
      before do
        click_button 'Mark as solved'
      end

      scenario 'The proposal dissapears from the list' do
        expect(page).not_to have_content(task.source.proposal.title)
      end
    end
  end
end
