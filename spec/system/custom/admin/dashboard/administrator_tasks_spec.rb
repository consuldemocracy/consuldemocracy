require "rails_helper"

describe "Admin administrator tasks", :admin do
  context "when visiting index" do
    context "and actions defined" do
      let!(:task) { create :dashboard_administrator_task, :pending }

      before do
        visit admin_dashboard_administrator_tasks_path
      end

      scenario "shows a message if proposal has been deleted" do
        proposal = task.source.proposal
        proposal.update!(hidden_at: Time.current)

        visit admin_dashboard_administrator_tasks_path

        expect(page).to have_content("This proposal has been deleted")
      end
    end
  end
end
