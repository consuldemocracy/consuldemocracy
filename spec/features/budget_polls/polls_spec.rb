require 'rails_helper'

feature "Polls" do

  context "Admin index" do
    it 'Budget polls should not appear in the list' do
      login_as(create(:administrator).user)

      poll = create(:poll)
      budget_poll = create(:poll, budget: create(:budget))

      visit admin_polls_path

      expect(page).to have_content(poll.name)
      expect(page).not_to have_content(budget_poll.name)
    end
  end

end
