require 'rails_helper'

feature 'Meetings' do
  scenario "Index page don't show past events by default", :js do
    create(:meeting, title: "Meeting 1")
    create(:meeting, title: "Meeting 2", held_at: Date.yesterday)
    create(:meeting, title: "Meeting 3")

    user = create(:user)
    login_as(user)

    visit meetings_path

    expect(page).to have_content("Meeting 1")
    expect(page).to_not have_content("Meeting 2")
    expect(page).to have_content("Meeting 3")
  end
end
