require "rails_helper"

describe "Admin Notifications", :admin do
  before { create(:budget) }

  context "Show" do
    scenario "Valid Admin Notification" do
      notification = create(:admin_notification, title: "Notification title",
                                                 body: "Notification body",
                                                 link: "https://www.decide.madrid.es/vota",
                                                 segment_recipient: :all_users)

      visit admin_admin_notification_path(notification)

      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")
      expect(page).to have_content("https://www.decide.madrid.es/vota")
      expect(page).to have_content("All users")
    end

    scenario "Notification with invalid segment recipient" do
      invalid_notification = create(:admin_notification)
      invalid_notification.update_column(:segment_recipient, "invalid_segment")

      visit admin_admin_notification_path(invalid_notification)

      expect(page).to have_content("Recipients user segment is invalid")
    end
  end

  context "Index" do
    scenario "Valid Admin Notifications", :with_frozen_time do
      draft = create(:admin_notification, segment_recipient: :all_users, title: "Not yet sent")
      sent = create(:admin_notification, :sent, segment_recipient: :administrators,
                                                title: "Sent one")

      visit admin_admin_notifications_path

      expect(page).to have_css(".admin_notification", count: 2)

      within("#admin_notification_#{draft.id}") do
        expect(page).to have_content("Not yet sent")
        expect(page).to have_content("All users")
        expect(page).to have_content("Draft")
      end

      within("#admin_notification_#{sent.id}") do
        expect(page).to have_content("Sent one")
        expect(page).to have_content("Administrators")
        expect(page).to have_content(I18n.l(Date.current))
      end
    end

    scenario "Notifications with invalid segment recipient" do
      invalid_notification = create(:admin_notification)
      invalid_notification.update_column(:segment_recipient, "invalid_segment")

      visit admin_admin_notifications_path

      expect(page).to have_content("Recipients user segment is invalid")
    end
  end

  scenario "Create" do
    visit admin_admin_notifications_path
    click_link "New notification"

    fill_in_admin_notification_form(segment_recipient: "Proposal authors",
                                    title: "This is a title",
                                    body: "This is a body",
                                    link: "http://www.dummylink.dev")

    click_button "Create notification"

    expect(page).to have_content "Notification created successfully"
    expect(page).to have_content "Proposal authors"
    expect(page).to have_content "This is a title"
    expect(page).to have_content "This is a body"
    expect(page).to have_content "http://www.dummylink.dev"
  end

  context "Update" do
    scenario "A draft notification can be updated" do
      notification = create(:admin_notification)

      visit admin_admin_notifications_path
      within("#admin_notification_#{notification.id}") do
        click_link "Edit"
      end

      fill_in_admin_notification_form(segment_recipient: "All users",
                                      title: "Other title",
                                      body: "Other body",
                                      link: "")

      click_button "Update notification"

      expect(page).to have_content "Notification updated successfully"
      expect(page).to have_content "All users"
      expect(page).to have_content "Other title"
      expect(page).to have_content "Other body"
      expect(page).not_to have_content "http://www.dummylink.dev"
    end

    scenario "Sent notification can not be updated" do
      notification = create(:admin_notification, :sent)

      visit admin_admin_notifications_path
      within("#admin_notification_#{notification.id}") do
        expect(page).not_to have_link("Edit")
      end
    end
  end

  context "Destroy" do
    scenario "A draft notification can be destroyed" do
      notification = create(:admin_notification)

      visit admin_admin_notifications_path

      confirmation = "Are you sure? This action will delete \"#{notification.title}\" and can't be undone."
      within("#admin_notification_#{notification.id}") do
        accept_confirm(confirmation) { click_button "Delete" }
      end

      expect(page).to have_content "Notification deleted successfully"
      expect(page).to have_css(".notification", count: 0)
    end

    scenario "Sent notification can not be destroyed" do
      notification = create(:admin_notification, :sent)

      visit admin_admin_notifications_path

      within("#admin_notification_#{notification.id}") do
        expect(page).not_to have_button "Delete"
      end
    end
  end

  context "Visualize" do
    scenario "A draft notification can be previewed" do
      notification = create(:admin_notification, segment_recipient: :administrators)

      visit admin_admin_notifications_path
      within("#admin_notification_#{notification.id}") do
        click_link "Preview"
      end

      expect(page).to have_content "This is how the users will see the notification:"
      expect(page).to have_content "Administrators (1 users will be notified)"
    end

    scenario "A sent notification can be viewed" do
      notification = create(:admin_notification, :sent, recipients_count: 7,
                                                        segment_recipient: :administrators)

      visit admin_admin_notifications_path
      within("#admin_notification_#{notification.id}") do
        click_link "View"
      end

      expect(page).to have_content "This is how the users see the notification:"
      expect(page).to have_content "Administrators (7 users got notified)"
    end
  end

  scenario "Errors on create" do
    visit new_admin_admin_notification_path

    click_button "Create notification"

    expect(page).to have_content error_message
  end

  scenario "Errors on update" do
    notification = create(:admin_notification)
    visit edit_admin_admin_notification_path(notification)

    fill_in "Title", with: ""
    click_button "Update notification"

    expect(page).to have_content error_message
  end

  context "Send notification" do
    scenario "A draft Admin notification can be sent" do
      2.times { create(:user) }
      notification = create(:admin_notification, segment_recipient: :all_users)

      visit admin_admin_notification_path(notification)

      accept_confirm { click_button "Send notification" }

      expect(page).to have_content "Notification sent successfully"
      expect(page).to have_content "3 users got notified"
    end

    scenario "A sent Admin notification can not be sent" do
      notification = create(:admin_notification, :sent)

      visit admin_admin_notification_path(notification)

      expect(page).not_to have_link("Send")
    end

    scenario "Admin notification with invalid segment recipient cannot be sent" do
      invalid_notification = create(:admin_notification)
      invalid_notification.update_column(:segment_recipient, "invalid_segment")
      visit admin_admin_notification_path(invalid_notification)

      expect(page).not_to have_link("Send")
    end
  end

  scenario "Select list of users to send notification" do
    segment = UserSegments.segments.sample
    segment_recipient = UserSegments.segment_name(segment)

    visit new_admin_admin_notification_path

    fill_in_admin_notification_form(segment_recipient: segment_recipient)
    click_button "Create notification"

    expect(page).to have_content segment_recipient
  end
end
