require "rails_helper"

feature "Moderate proposal notifications" do

  scenario "Hide", :js do
    citizen   = create(:user)
    proposal  = create(:proposal)
    proposal_notification = create(:proposal_notification, proposal: proposal, created_at: Date.current - 4.days)
    moderator = create(:moderator)

    login_as(moderator.user)
    visit proposal_path(proposal)
    click_link "Notifications (1)"

    within("#proposal_notification_#{proposal_notification.id}") do
      accept_confirm { click_link "Hide" }
    end

    expect(page).to have_css("#proposal_notification_#{proposal_notification.id}.faded")

    logout
    login_as(citizen)
    visit proposal_path(proposal)

    expect(page).to have_content "Notifications (0)"
  end

  scenario "Can not hide own proposal notification" do
    moderator = create(:moderator)
    proposal = create(:proposal, author: moderator.user)
    proposal_notification = create(:proposal_notification, proposal: proposal, created_at: Date.current - 4.days)

    login_as(moderator.user)
    visit proposal_path(proposal)

    within("#proposal_notification_#{proposal_notification.id}") do
      expect(page).not_to have_link("Hide")
      expect(page).not_to have_link("Block author")
    end
  end

  feature "/moderation/ screen" do

    background do
      moderator = create(:moderator)
      login_as(moderator.user)
    end

    feature "moderate in bulk" do
      feature "When a proposal has been selected for moderation" do
        background do
          proposal = create(:proposal)
          @proposal_notification = create(:proposal_notification, proposal: proposal, created_at: Date.current - 4.days)
          visit moderation_proposal_notifications_path
          within(".menu.simple") do
            click_link "All"
          end

          within("#proposal_notification_#{@proposal_notification.id}") do
            check "proposal_notification_#{@proposal_notification.id}_check"
          end
        end

        scenario "Hide the proposal" do
          click_on "Hide proposals"
          expect(page).not_to have_css("#proposal_notification_#{@proposal_notification.id}")
          expect(@proposal_notification.reload).to be_hidden
          expect(@proposal_notification.author).not_to be_hidden
        end

        scenario "Block the author" do
          author = create(:user)
          @proposal_notification.update(author: author)
          click_on "Block authors"
          expect(page).not_to have_css("#proposal_notification_#{@proposal_notification.id}")
          expect(@proposal_notification.reload).to be_hidden
          expect(author.reload).to be_hidden
        end

        scenario "Ignore the proposal" do
          click_button "Mark as viewed"

          expect(@proposal_notification.reload).to be_ignored
          expect(@proposal_notification.reload).not_to be_hidden
          expect(@proposal_notification.author).not_to be_hidden
        end
      end

      scenario "select all/none", :js do
        create_list(:proposal_notification, 2)

        visit moderation_proposal_notifications_path

        within(".js-check") { click_on "All" }

        expect(all("input[type=checkbox]")).to all(be_checked)

        within(".js-check") { click_on "None" }

        all("input[type=checkbox]").each do |checkbox|
          expect(checkbox).not_to be_checked
        end
      end

      scenario "remembering page, filter and order" do
        create_list(:proposal, 52)

        visit moderation_proposal_notifications_path(filter: "all", page: "2", order: "created_at")

        click_button "Mark as viewed"

        expect(page).to have_selector(".js-order-selector[data-order='created_at']")

        expect(current_url).to include("filter=all")
        expect(current_url).to include("page=2")
        expect(current_url).to include("order=created_at")
      end
    end

    scenario "Current filter is properly highlighted" do
      visit moderation_proposal_notifications_path
      expect(page).not_to have_link("Pending review")
      expect(page).to have_link("All")
      expect(page).to have_link("Mark as viewed")

      visit moderation_proposal_notifications_path(filter: "all")
      within(".menu.simple") do
        expect(page).not_to have_link("All")
        expect(page).to have_link("Pending review")
        expect(page).to have_link("Mark as viewed")
      end

      visit moderation_proposal_notifications_path(filter: "pending_review")
      within(".menu.simple") do
        expect(page).to have_link("All")
        expect(page).not_to have_link("Pending review")
        expect(page).to have_link("Mark as viewed")
      end

      visit moderation_proposal_notifications_path(filter: "ignored")
      within(".menu.simple") do
        expect(page).to have_link("All")
        expect(page).to have_link("Pending review")
        expect(page).not_to have_link("Marked as viewed")
      end
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
      moderated_notification = create(:proposal_notification, :moderated, title: "Moderated notification", created_at: Time.current - 1.day)
      moderated_new_notification = create(:proposal_notification, :moderated, title: "Moderated new notification", created_at: Time.current - 12.hours)
      newer_notification = create(:proposal_notification, title: "Newer notification", created_at: Time.current)
      old_moderated_notification = create(:proposal_notification, :moderated, title: "Older notification", created_at: Time.current - 2.days)

      visit moderation_proposal_notifications_path(filter: "all", order: "created_at")

      expect(moderated_new_notification.title).to appear_before(moderated_notification.title)

      visit moderation_proposal_notifications_path(filter: "all", order: "moderated")

      expect(old_moderated_notification.title).to appear_before(newer_notification.title)
    end
  end
end
