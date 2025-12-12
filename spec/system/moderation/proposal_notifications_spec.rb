require "rails_helper"

describe "Moderate proposal notifications" do
  describe "/moderation/ screen" do
    before do
      moderator = create(:moderator)
      login_as(moderator.user)
    end

    describe "moderate in bulk" do
      scenario "select all/none" do
        create_list(:proposal_notification, 2)

        visit moderation_proposal_notifications_path
        click_link "All"

        expect(page).to have_field type: :checkbox, count: 2

        within(".check-all-none") { click_button "Select all" }

        expect(all(:checkbox)).to all(be_checked)

        within(".check-all-none") { click_button "Select none" }

        all(:checkbox).each { |checkbox| expect(checkbox).not_to be_checked }
      end

      scenario "remembering page, filter and order" do
        stub_const("#{ModerateActions}::PER_PAGE", 2)
        create_list(:proposal_notification, 4)

        visit moderation_proposal_notifications_path(filter: "all", page: "2", order: "created_at")

        accept_confirm("Are you sure? Mark as viewed") { click_button "Mark as viewed" }

        expect(page).to have_link "Most recent", class: "is-active"
        expect(page).to have_link "Moderated"

        expect(page).to have_current_path(/filter=all/)
        expect(page).to have_current_path(/page=2/)
        expect(page).to have_current_path(/order=created_at/)
      end
    end

    scenario "Current filter is properly highlighted" do
      visit moderation_proposal_notifications_path
      expect(page).not_to have_link("Pending")
      expect(page).to have_link("All")
      expect(page).to have_link("Marked as viewed")

      visit moderation_proposal_notifications_path(filter: "all")
      expect(page).not_to have_link("All")
      expect(page).to have_link("Pending")
      expect(page).to have_link("Marked as viewed")

      visit moderation_proposal_notifications_path(filter: "pending_review")
      expect(page).to have_link("All")
      expect(page).not_to have_link("Pending")
      expect(page).to have_link("Marked as viewed")

      visit moderation_proposal_notifications_path(filter: "ignored")
      expect(page).to have_link("All")
      expect(page).to have_link("Pending")
      expect(page).not_to have_link("Marked as viewed")
    end

    scenario "Filtering proposals" do
      proposal = create(:proposal)
      create(:proposal_notification, title: "Regular proposal", proposal: proposal)
      create(:proposal_notification, :moderated, title: "Pending proposal", proposal: proposal)
      create(:proposal_notification, :hidden, title: "Hidden proposal", proposal: proposal)
      create(:proposal_notification, :moderated, :ignored, title: "Ignored proposal", proposal: proposal)

      visit moderation_proposal_notifications_path(filter: "all")
      expect(page).to have_content("Regular proposal")
      expect(page).to have_content("Pending proposal")
      expect(page).not_to have_content("Hidden proposal")
      expect(page).to have_content("Ignored proposal")

      visit moderation_proposal_notifications_path(filter: "pending_review")
      expect(page).not_to have_content("Regular proposal")
      expect(page).to have_content("Pending proposal")
      expect(page).not_to have_content("Hidden proposal")
      expect(page).not_to have_content("Ignored proposal")

      visit moderation_proposal_notifications_path(filter: "ignored")
      expect(page).not_to have_content("Regular proposal")
      expect(page).not_to have_content("Pending proposal")
      expect(page).not_to have_content("Hidden proposal")
      expect(page).to have_content("Ignored proposal")
    end

    scenario "sorting proposal notifications" do
      moderated_notification = create(:proposal_notification,
                                      :moderated,
                                      title: "Moderated notification",
                                      created_at: 1.day.ago)
      moderated_new_notification = create(:proposal_notification,
                                          :moderated,
                                          title: "Moderated new notification",
                                          created_at: 12.hours.ago)
      newer_notification = create(:proposal_notification,
                                  title: "Newer notification",
                                  created_at: Time.current)
      old_moderated_notification = create(:proposal_notification,
                                          :moderated,
                                          title: "Older notification",
                                          created_at: 2.days.ago)

      visit moderation_proposal_notifications_path(filter: "all", order: "created_at")

      expect(moderated_new_notification.title).to appear_before(moderated_notification.title)

      visit moderation_proposal_notifications_path(filter: "all", order: "moderated")

      expect(old_moderated_notification.title).to appear_before(newer_notification.title)
    end
  end
end
