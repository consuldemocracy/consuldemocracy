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
    end
  end
end
