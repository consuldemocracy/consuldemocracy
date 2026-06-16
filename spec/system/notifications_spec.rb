require "rails_helper"

describe "Notifications" do
  let(:user) { create(:user) }
  before { login_as(user) }

  context "Admin Notifications" do
    let(:admin_notification) do
      create(:admin_notification, title: "Notification title",
                                  body: "Notification body",
                                  link: "https://www.external.link.dev/",
                                  segment_recipient: "all_users")
    end

    let!(:notification) do
      create(:notification, user: user, notifiable: admin_notification)
    end

    before do
      login_as user
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end

    scenario "With external link" do
      proxy.stub("https://www.external.link.dev:443/").and_return(body: "<html></html>", code: 200)

      visit notifications_path
      expect(page).to have_content("Notification title")
      expect(page).to have_content("Notification body")

      first("#notification_#{notification.id} a").click

      expect(page).to have_current_path "https://www.external.link.dev/"
    end
  end
end
