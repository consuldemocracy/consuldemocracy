require "rails_helper"

describe "Admin administrator tasks", :admin do
  context "when visiting index" do
    context "and no pending tasks" do
      before do
        visit admin_dashboard_administrator_tasks_path
      end

      scenario "shows that there are no records available" do
        expect(page).to have_content("There are no resources requested")
      end
    end

    context "and actions defined" do
      let!(:task) { create :dashboard_administrator_task, :pending }

      before do
        visit admin_dashboard_administrator_tasks_path
      end

      scenario "shows the task data" do
        expect(page).to have_content(task.source.proposal.title)
        expect(page).to have_content(task.source.action.title)
      end

      scenario "has a link that allows solving the request" do
        expect(page).to have_link("Solve")
      end
    end
  end

  context "when solving a task" do
    let!(:task) { create :dashboard_administrator_task, :pending }

    before do
      visit admin_dashboard_administrator_tasks_path
      click_link "Solve"
    end

    scenario "Shows task details and link to proposal" do
      expect(page).to have_link(task.source.proposal.title)
      expect(page).to have_content(task.source.action.title)
    end

    scenario "contains a button that solves the request" do
      expect(page).to have_button("Mark as solved")
    end

    scenario "After it is solved appears on solved filter" do
      click_button "Mark as solved"

      expect(page).not_to have_link(task.source.proposal.title)
      expect(page).not_to have_content(task.source.action.title)
      expect(page).to have_content("The task has been marked as solved")

      within("#filter-subnav") do
        click_link "Solved"
      end

      expect(page).to have_content(task.source.proposal.title)
      expect(page).to have_content(task.source.action.title)
      expect(page).not_to have_link("Solve")
    end
  end
end
