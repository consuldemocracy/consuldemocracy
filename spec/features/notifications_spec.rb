require 'rails_helper'

feature "Notifications" do

  let(:user) { create :user }

  background do
    login_as(user)
    visit root_path
  end

  scenario "View all" do
    read1 = create(:notification, :read, user: user)
    read2 = create(:notification, :read, user: user)
    unread = create(:notification, user: user)

    click_notifications_icon
    click_link "Read"

    expect(page).to have_css(".notification", count: 2)
    expect(page).to have_content(read1.notifiable_title)
    expect(page).to have_content(read2.notifiable_title)
    expect(page).to_not have_content(unread.notifiable_title)
  end

  scenario "View unread" do
    unread1 = create(:notification, user: user)
    unread2 = create(:notification, user: user)
    read = create(:notification, :read, user: user)

    click_notifications_icon
    click_link "Unread"

    expect(page).to have_css(".notification", count: 2)
    expect(page).to have_content(unread1.notifiable_title)
    expect(page).to have_content(unread2.notifiable_title)
    expect(page).to_not have_content(read.notifiable_title)
  end

  scenario "View single notification" do
    proposal = create(:proposal)
    notification = create(:notification, user: user, notifiable: proposal)

    click_notifications_icon

    first(".notification a").click
    expect(page).to have_current_path(proposal_path(proposal))

    visit notifications_path
    expect(page).to have_css ".notification", count: 0

    visit read_notifications_path
    expect(page).to have_css ".notification", count: 1
  end

  scenario "Mark as read", :js do
    notification1 = create(:notification, user: user)
    notification2 = create(:notification, user: user)

    click_notifications_icon

    within("#notification_#{notification1.id}") do
      click_link "Mark as read"
    end

    expect(page).to have_css(".notification", count: 1)
    expect(page).to have_content(notification2.notifiable_title)
    expect(page).to_not have_content(notification1.notifiable_title)
  end

  scenario "Mark all as read" do
    notification1 = create(:notification, user: user)
    notification2 = create(:notification, user: user)

    click_notifications_icon

    expect(page).to have_css(".notification", count: 2)
    click_link "Mark all as read"

    expect(page).to have_css(".notification", count: 0)
  end

  scenario "Mark as unread", :js do
    notification1 = create(:notification, :read, user: user)
    notification2 = create(:notification, user: user)

    click_notifications_icon
    click_link "Read"

    expect(page).to have_css(".notification", count: 1)
    within("#notification_#{notification1.id}") do
      click_link "Mark as unread"
    end

    expect(page).to have_css(".notification", count: 0)

    visit notifications_path
    expect(page).to have_css(".notification", count: 2)
    expect(page).to have_content(notification1.notifiable_title)
    expect(page).to have_content(notification2.notifiable_title)
  end

  scenario "Bell" do
    create(:notification, user: user)
    visit root_path

    within("#notifications") do
      expect(page).to have_css(".icon-circle")
    end

    click_notifications_icon
    first(".notification a").click

    within("#notifications") do
      expect(page).to_not have_css(".icon-circle")
    end
  end

  scenario "No notifications" do
    click_notifications_icon
    expect(page).to have_content "You don't have new notifications."
  end

  scenario "User not logged in" do
    logout
    visit root_path

    expect(page).to_not have_css("#notifications")
  end

  scenario "Notification's notifiable model no longer includes Notifiable module" do
    create(:notification, notifiable: create(:spending_proposal), user: user)
    create(:notification, notifiable: create(:poll_question), user: user)

    click_notifications_icon
    expect(page).to have_content('This resource is not available anymore.', count: 2)
  end

  context "Admin Notifications" do
    let(:admin_notification) do
      create(:admin_notification, title: 'Notification title',
                                  body: 'Notification body',
                                  link: 'https://www.external.link.dev/',
                                  segment_recipient: 'all_users')
    end

    let!(:notification) do
      create(:notification, user: user, notifiable: admin_notification)
    end

    before do
      login_as user
    end

    scenario "With external link" do
      visit notifications_path
      expect(page).to have_content('Notification title')
      expect(page).to have_content('Notification body')

      first("#notification_#{notification.id} a").click
      expect(page.current_url).to eq('https://www.external.link.dev/')
    end

    scenario "With internal link" do
      admin_notification.update_attributes(link: '/stats')

      visit notifications_path
      expect(page).to have_content('Notification title')
      expect(page).to have_content('Notification body')

      first("#notification_#{notification.id} a").click
      expect(page).to have_current_path('/stats')
    end

    scenario "Without a link" do
      admin_notification.update_attributes(link: '/stats')

      visit notifications_path
      expect(page).to have_content('Notification title')
      expect(page).to have_content('Notification body')
      expect(page).not_to have_link(notification_path(notification), visible: false)
    end
  end

  describe "#send_pending" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:user3) { create(:user) }
    let!(:proposal_notification) { create(:proposal_notification) }
    let!(:notification1) { create(:notification, notifiable: proposal_notification, user: user1) }
    let!(:notification2) { create(:notification, notifiable: proposal_notification, user: user2) }
    let!(:notification3) { create(:notification, notifiable: proposal_notification, user: user3) }

    before do
      reset_mailer
      Delayed::Worker.delay_jobs = true
    end

    after do
      Delayed::Worker.delay_jobs = false
    end

    it "sends pending proposal notifications" do
      Delayed::Worker.delay_jobs = false
      Notification.send_pending

      email = open_last_email
      expect(email).to have_subject("Proposal notifications in CONSUL")
    end

    it "sends emails in batches" do
      Notification.send_pending

      expect(Delayed::Job.count).to eq(3)
    end

    it "sends batches in time intervals" do
      allow(Notification).to receive(:batch_size).and_return(1)
      allow(Notification).to receive(:batch_interval).and_return(1.second)
      allow(Notification).to receive(:first_batch_run_at).and_return(Time.current)

      remove_users_without_pending_notifications

      Notification.send_pending

      now = Notification.first_batch_run_at
      first_batch_run_at  = now.change(usec: 0)
      second_batch_run_at = (now + 1.second).change(usec: 0)
      third_batch_run_at  = (now + 2.seconds).change(usec: 0)

      expect(Delayed::Job.count).to eq(3)
      expect(Delayed::Job.first.run_at.change(usec: 0)).to eq(first_batch_run_at)
      expect(Delayed::Job.second.run_at.change(usec: 0)).to eq(second_batch_run_at)
      expect(Delayed::Job.third.run_at.change(usec: 0)).to eq(third_batch_run_at)
    end

  end

  def remove_users_without_pending_notifications
    users_without_notifications.each { |user| user.destroy }
  end

  def users_without_notifications
    User.all.select { |user| user.notifications.not_emailed
                             .where(notifiable_type: 'ProposalNotification').blank? }
  end

end
