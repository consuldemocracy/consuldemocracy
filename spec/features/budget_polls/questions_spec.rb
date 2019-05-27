require "rails_helper"

feature "Poll Questions" do

  before do
    admin = create(:administrator).user
    login_as(admin)
  end

  scenario "Do not display polls associated to a budget" do
    budget = create(:budget)

    poll1 = create(:poll, name: "Citizen Proposal Poll")
    poll2 = create(:poll, budget: budget, name: "Participatory Budget Poll")

    visit admin_questions_path

    expect(page).to have_select("poll_id", text: "Citizen Proposal Poll")
    expect(page).not_to have_select("poll_id", text: "Participatory Budget Poll")
  end

end
