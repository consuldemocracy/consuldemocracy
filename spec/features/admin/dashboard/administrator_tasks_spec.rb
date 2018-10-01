require 'rails_helper'

feature 'Admin administrator tasks' do
  let(:admin) { create :administrator }

  before do
    login_as(admin.user)
  end

  context 'when visiting index' do
    context 'and no pending tasks' do
      before do
        visit admin_dashboard_administrator_tasks_path
      end

      scenario 'shows that there are no records available' do
        expect(page).to have_content('There are no pending tasks')
      end
    end

    context 'and actions defined' do
      let!(:task) { create :dashboard_administrator_task, :pending }

      before do
        visit admin_dashboard_administrator_tasks_path
      end

      scenario 'shows the task data' do
        expect(page).to have_content(task.source.proposal.title)
        expect(page).to have_content(task.source.action.title)
      end
      
      scenario 'has a link that allows solving the request' do
        expect(page).to have_link('Solve')
      end

    end
  end

  context 'when solving a task' do
    let!(:task) { create :dashboard_administrator_task, :pending }

    before do
      visit admin_dashboard_administrator_tasks_path
      click_link 'Solve'
    end

    scenario 'Shows task details' do
      expect(page).to have_content(task.source.proposal.title)
      expect(page).to have_content(task.source.action.title)
    end
    
    scenario 'contains a link to the proposal' do
      expect(page).to have_link('Check the proposal details')
    end

    scenario 'contains a button that solves the request' do
      expect(page).to have_button('Mark as solved')
    end

    scenario 'After it is solved dissapears from the list' do
      click_button 'Mark as solved'

      expect(page).not_to have_content(task.source.proposal.title)
      expect(page).not_to have_content(task.source.action.title)
      expect(page).to have_content('The task has been marked as solved')
    end
  end
end

