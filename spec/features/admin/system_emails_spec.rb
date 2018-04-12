require 'rails_helper'

feature "System Emails" do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  context "Index" do
    scenario "Lists all system emails with correct actions" do
      visit admin_system_emails_path

      within('#proposal_notification_digest') do
        expect(page).to have_link('View')
      end
    end
  end

  context "View" do
    scenario "#proposal_notification_digest" do
      proposal_a = create(:proposal, title: 'Proposal A')
      proposal_b = create(:proposal, title: 'Proposal B')
      proposal_notification_a = create(:proposal_notification, proposal: proposal_a,
                                                               title: 'Proposal A Title',
                                                               body: 'Proposal A Notification Body')
      proposal_notification_b = create(:proposal_notification, proposal: proposal_b,
                                                               title: 'Proposal B Title',
                                                               body: 'Proposal B Notification Body')
      notification_a = create(:notification, notifiable: proposal_notification_a)
      notification_b = create(:notification, notifiable: proposal_notification_b)

      visit admin_system_email_view_path('proposal_notification_digest')

      expect(page).to have_content('Proposal notifications in')
      expect(page).to have_link('Proposal A Title', href: notification_url(notification_a))
      expect(page).to have_link('Proposal B Title', href: notification_url(notification_b))
      expect(page).to have_content('Proposal A Notification Body')
      expect(page).to have_content('Proposal B Notification Body')
    end
  end

end
