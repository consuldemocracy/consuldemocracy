require 'rails_helper'

feature "Notifications" do

  let(:user) { create :user }

  context "mark as read" do

    scenario "mark a single notification as read" do
      notification = create :notification, user: user

      login_as user
      visit notifications_path

      expect(page).to have_css ".notification", count: 1

      first(".notification a").click
      visit notifications_path

      expect(page).to have_css ".notification", count: 0
    end

    scenario "mark all notifications as read" do
      2.times { create :notification, user: user }

      login_as user
      visit notifications_path

      expect(page).to have_css ".notification", count: 2
      click_link "Mark all as read"

      expect(page).to have_css ".notification", count: 0
      expect(page).to have_current_path(notifications_path)
    end

  end

  scenario "no notifications" do
    login_as user
    visit notifications_path

    expect(page).to have_content "You don't have new notifications"
  end

end
