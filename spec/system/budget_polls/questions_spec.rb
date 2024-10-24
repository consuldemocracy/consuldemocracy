require "rails_helper"

describe "Poll Questions", :admin do
  scenario "Do not display polls associated to a budget" do
    create(:poll, name: "Citizen Proposal Poll")
    create(:poll, :for_budget, name: "Participatory Budget Poll")

    visit admin_questions_path

    expect(page).to have_select("poll_id", text: "Citizen Proposal Poll")
    expect(page).not_to have_select("poll_id", text: "Participatory Budget Poll")
  end
end
