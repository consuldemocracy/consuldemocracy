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
      create(:notification, notifiable: proposal_notification_a)
      create(:notification, notifiable: proposal_notification_b)

      visit admin_system_email_view_path('proposal_notification_digest')

      expect(page).to have_content('Proposal notifications in')
      expect(page).to have_link('Proposal A Title', href: proposal_url(proposal_a,
                                                    anchor: 'tab-notifications'))
      expect(page).to have_link('Proposal B Title', href: proposal_url(proposal_b,
                                                    anchor: 'tab-notifications'))
      expect(page).to have_content('Proposal A Notification Body')
      expect(page).to have_content('Proposal B Notification Body')
    end
  end

  context "Preview Pending" do
    scenario "#proposal_notification_digest" do
      proposal_a = create(:proposal, title: 'Proposal A')
      proposal_b = create(:proposal, title: 'Proposal B')
      proposal_notification_a = create(:proposal_notification, proposal: proposal_a,
                                                               title: 'Proposal A Title',
                                                               body: 'Proposal A Notification Body')
      proposal_notification_b = create(:proposal_notification, proposal: proposal_b,
                                                               title: 'Proposal B Title',
                                                               body: 'Proposal B Notification Body')
      create(:notification, notifiable: proposal_notification_a, emailed_at: nil)
      create(:notification, notifiable: proposal_notification_b, emailed_at: nil)

      visit admin_system_email_preview_pending_path('proposal_notification_digest')

      expect(page).to have_content('This is the content pending to be sent')
      expect(page).to have_link('Proposal A', href: proposal_url(proposal_a))
      expect(page).to have_link('Proposal B', href: proposal_url(proposal_b))
      expect(page).to have_link('Proposal A Title', href: proposal_url(proposal_a,
                                                    anchor: 'tab-notifications'))
      expect(page).to have_link('Proposal B Title', href: proposal_url(proposal_b,
                                                    anchor: 'tab-notifications'))
    end

    scenario "#moderate_pending" do
      proposal1 = create(:proposal, title: 'Proposal A')
      proposal2 = create(:proposal, title: 'Proposal B')
      proposal_notification1 = create(:proposal_notification, proposal: proposal1,
                                                               title: 'Proposal A Title',
                                                               body: 'Proposal A Notification Body')
      proposal_notification2 = create(:proposal_notification, proposal: proposal2)
      create(:notification, notifiable: proposal_notification1, emailed_at: nil)
      create(:notification, notifiable: proposal_notification2, emailed_at: nil)

      visit admin_system_email_preview_pending_path('proposal_notification_digest')

      within("#proposal_notification_#{proposal_notification1.id}") do
        click_on "Moderate notification send"
      end

      visit admin_system_email_preview_pending_path('proposal_notification_digest')

      expect(Notification.count).to equal(1)
      expect(Activity.last.actionable_type).to eq('ProposalNotification')
      expect(page).not_to have_content("Proposal A Title")
    end

    scenario "#send_pending" do
      proposal = create(:proposal)
      proposal_notification = create(:proposal_notification, proposal: proposal,
                                                              title: 'Proposal A Title',
                                                              body: 'Proposal A Notification Body')
      voter = create(:user, :level_two)
      create(:notification, notifiable: proposal_notification, user: voter, emailed_at: nil)
      create(:follow, user: voter, followable: proposal)

      visit admin_system_emails_path

      click_on "Send pending"

      email = open_last_email
      expect(email).to deliver_to(voter)
      expect(email).to have_body_text(proposal_notification.body)

      expect(page).to have_content("Pending notifications sent succesfully")
    end
  end

end
