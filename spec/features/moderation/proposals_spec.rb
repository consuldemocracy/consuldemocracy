require "rails_helper"

feature "Moderate proposals" do

  scenario "Disabled with a feature flag" do
    Setting["feature.proposals"] = nil
    moderator = create(:moderator)
    login_as(moderator.user)

    expect{ visit moderation_proposals_path }.to raise_exception(FeatureFlags::FeatureDisabled)

    Setting["feature.proposals"] = true
  end

  scenario "Hide", :js do
    citizen   = create(:user)
    proposal  = create(:proposal)
    moderator = create(:moderator)

    login_as(moderator.user)
    visit proposal_path(proposal)

    within("#proposal_#{proposal.id}") do
      accept_confirm { click_link "Hide" }
    end

    expect(page).to have_css("#proposal_#{proposal.id}.faded")

    login_as(citizen)
    visit proposals_path

    expect(page).to have_css(".proposal", count: 0)
  end

  scenario "Can not hide own proposal" do
    moderator = create(:moderator)
    proposal = create(:proposal, author: moderator.user)

    login_as(moderator.user)
    visit proposal_path(proposal)

    within("#proposal_#{proposal.id}") do
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
          @proposal = create(:proposal)
          visit moderation_proposals_path
          within(".menu.simple") do
            click_link "All"
          end

          within("#proposal_#{@proposal.id}") do
            check "proposal_#{@proposal.id}_check"
          end

          expect(page).not_to have_css("proposal_#{@proposal.id}")
        end

        scenario "Hide the proposal" do
          click_on "Hide proposals"
          expect(page).not_to have_css("proposal_#{@proposal.id}")
          expect(@proposal.reload).to be_hidden
          expect(@proposal.author).not_to be_hidden
        end

        scenario "Block the author" do
          click_on "Block authors"
          expect(page).not_to have_css("proposal_#{@proposal.id}")
          expect(@proposal.reload).to be_hidden
          expect(@proposal.author).to be_hidden
        end

        scenario "Ignore the proposal" do
          click_button "Mark as viewed"
          expect(page).not_to have_css("proposal_#{@proposal.id}")
          expect(@proposal.reload).to be_ignored_flag
          expect(@proposal.reload).not_to be_hidden
          expect(@proposal.author).not_to be_hidden
        end
      end

      scenario "select all/none", :js do
        create_list(:proposal, 2)

        visit moderation_proposals_path

        within(".js-check") { click_on "All" }

        expect(all("input[type=checkbox]")).to all(be_checked)

        within(".js-check") { click_on "None" }

        all("input[type=checkbox]").each do |checkbox|
          expect(checkbox).not_to be_checked
        end
      end

      scenario "remembering page, filter and order" do
        create_list(:proposal, 52)

        visit moderation_proposals_path(filter: "all", page: "2", order: "created_at")

        click_button "Mark as viewed"

        expect(page).to have_selector(".js-order-selector[data-order='created_at']")

        expect(current_url).to include("filter=all")
        expect(current_url).to include("page=2")
        expect(current_url).to include("order=created_at")
      end
    end

    scenario "Current filter is properly highlighted" do
      visit moderation_proposals_path
      expect(page).not_to have_link("Pending")
      expect(page).to have_link("All")
      expect(page).to have_link("Mark as viewed")

      visit moderation_proposals_path(filter: "all")
      within(".menu.simple") do
        expect(page).not_to have_link("All")
        expect(page).to have_link("Pending review")
        expect(page).to have_link("Mark as viewed")
      end

      visit moderation_proposals_path(filter: "pending_flag_review")
      within(".menu.simple") do
        expect(page).to have_link("All")
        expect(page).not_to have_link("Pending")
        expect(page).to have_link("Mark as viewed")
      end

      visit moderation_proposals_path(filter: "with_ignored_flag")
      within(".menu.simple") do
        expect(page).to have_link("All")
        expect(page).to have_link("Pending review")
        expect(page).not_to have_link("Marked as viewed")
      end
    end

    scenario "Filtering proposals" do
      create(:proposal, title: "Regular proposal")
      create(:proposal, :flagged, title: "Pending proposal")
      create(:proposal, :hidden, title: "Hidden proposal")
      create(:proposal, :flagged, :with_ignored_flag, title: "Ignored proposal")

      visit moderation_proposals_path(filter: "all")
      expect(page).to have_content("Regular proposal")
      expect(page).to have_content("Pending proposal")
      expect(page).not_to have_content("Hidden proposal")
      expect(page).to have_content("Ignored proposal")

      visit moderation_proposals_path(filter: "pending_flag_review")
      expect(page).not_to have_content("Regular proposal")
      expect(page).to have_content("Pending proposal")
      expect(page).not_to have_content("Hidden proposal")
      expect(page).not_to have_content("Ignored proposal")

      visit moderation_proposals_path(filter: "with_ignored_flag")
      expect(page).not_to have_content("Regular proposal")
      expect(page).not_to have_content("Pending proposal")
      expect(page).not_to have_content("Hidden proposal")
      expect(page).to have_content("Ignored proposal")
    end

    scenario "sorting proposals" do
      flagged_proposal = create(:proposal, title: "Flagged proposal", created_at: Time.current - 1.day, flags_count: 5)
      flagged_new_proposal = create(:proposal, title: "Flagged new proposal", created_at: Time.current - 12.hours, flags_count: 3)
      newer_proposal = create(:proposal, title: "Newer proposal", created_at: Time.current)

      visit moderation_proposals_path(order: "created_at")

      expect(flagged_new_proposal.title).to appear_before(flagged_proposal.title)

      visit moderation_proposals_path(order: "flags")

      expect(flagged_proposal.title).to appear_before(flagged_new_proposal.title)

      visit moderation_proposals_path(filter: "all", order: "created_at")

      expect(newer_proposal.title).to appear_before(flagged_new_proposal.title)
      expect(flagged_new_proposal.title).to appear_before(flagged_proposal.title)

      visit moderation_proposals_path(filter: "all", order: "flags")

      expect(flagged_proposal.title).to appear_before(flagged_new_proposal.title)
      expect(flagged_new_proposal.title).to appear_before(newer_proposal.title)
    end
  end
end
