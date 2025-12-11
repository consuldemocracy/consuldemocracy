require "rails_helper"

describe "Moderate comments" do
  scenario "Can not hide own comment" do
    moderator = create(:moderator)
    comment = create(:comment, user: moderator.user)

    login_as(moderator.user)
    visit debate_path(comment.commentable)

    within("#comment_#{comment.id}") do
      expect(page).not_to have_button "Hide"
      expect(page).not_to have_button "Block author"
    end
  end

  scenario "Visit items with flagged comments" do
    moderator = create(:moderator)
    debate = create(:debate, title: "Debate with spam comment")
    proposal = create(:proposal, title: "Proposal with spam comment")
    create(:comment, commentable: debate, body: "This is SPAM comment on debate", flags_count: 2)
    create(:comment, commentable: proposal, body: "This is SPAM comment on proposal", flags_count: 2)

    login_as(moderator.user)
    visit moderation_comments_path

    expect(page).to have_content("Debate with spam comment")
    expect(page).to have_content("Proposal with spam comment")
    expect(page).to have_content("This is SPAM comment on debate")
    expect(page).to have_content("This is SPAM comment on proposal")

    click_link "Debate with spam comment"
    expect(page).to have_content("Debate with spam comment")
    expect(page).to have_content("This is SPAM comment on debate")

    visit moderation_comments_path

    click_link "Proposal with spam comment"
    expect(page).to have_content("Proposal with spam comment")
    expect(page).to have_content("This is SPAM comment on proposal")
  end

  describe "/moderation/ screen" do
    before do
      moderator = create(:moderator)
      login_as(moderator.user)
    end

    describe "moderate in bulk" do
      scenario "select all/none" do
        create_list(:comment, 2)

        visit moderation_comments_path
        click_link "All"

        expect(page).to have_field type: :checkbox, count: 2

        within(".check-all-none") { click_button "Select all" }

        expect(all(:checkbox)).to all(be_checked)

        within(".check-all-none") { click_button "Select none" }

        all(:checkbox).each { |checkbox| expect(checkbox).not_to be_checked }
      end
    end

    scenario "Current filter is properly highlighted" do
      visit moderation_comments_path
      expect(page).not_to have_link("Pending")
      expect(page).to have_link("All")
      expect(page).to have_link("Marked as viewed")

      visit moderation_comments_path(filter: "all")
      expect(page).not_to have_link("All")
      expect(page).to have_link("Pending")
      expect(page).to have_link("Marked as viewed")

      visit moderation_comments_path(filter: "pending_flag_review")
      expect(page).to have_link("All")
      expect(page).not_to have_link("Pending")
      expect(page).to have_link("Marked as viewed")

      visit moderation_comments_path(filter: "with_ignored_flag")
      expect(page).to have_link("All")
      expect(page).to have_link("Pending")
      expect(page).not_to have_link("Marked as viewed")
    end

    scenario "Filtering comments" do
      create(:comment, body: "Regular comment")
      create(:comment, :flagged, body: "Pending comment")
      create(:comment, :hidden, body: "Hidden comment")
      create(:comment, :flagged, :with_ignored_flag, body: "Ignored comment")

      visit moderation_comments_path(filter: "all")
      expect(page).to have_content("Regular comment")
      expect(page).to have_content("Pending comment")
      expect(page).not_to have_content("Hidden comment")
      expect(page).to have_content("Ignored comment")

      visit moderation_comments_path(filter: "pending_flag_review")
      expect(page).not_to have_content("Regular comment")
      expect(page).to have_content("Pending comment")
      expect(page).not_to have_content("Hidden comment")
      expect(page).not_to have_content("Ignored comment")

      visit moderation_comments_path(filter: "with_ignored_flag")
      expect(page).not_to have_content("Regular comment")
      expect(page).not_to have_content("Pending comment")
      expect(page).not_to have_content("Hidden comment")
      expect(page).to have_content("Ignored comment")
    end

    scenario "sorting comments" do
      flagged_comment = create(:comment,
                               body: "Flagged comment",
                               created_at: 1.day.ago,
                               flags_count: 5)
      flagged_new_comment = create(:comment,
                                   body: "Flagged new comment",
                                   created_at: 12.hours.ago,
                                   flags_count: 3)
      newer_comment = create(:comment, body: "Newer comment", created_at: Time.current)

      visit moderation_comments_path(order: "newest")

      expect(flagged_new_comment.body).to appear_before(flagged_comment.body)

      visit moderation_comments_path(order: "flags")

      expect(flagged_comment.body).to appear_before(flagged_new_comment.body)

      visit moderation_comments_path(filter: "all", order: "newest")

      expect(newer_comment.body).to appear_before(flagged_new_comment.body)
      expect(flagged_new_comment.body).to appear_before(flagged_comment.body)

      visit moderation_comments_path(filter: "all", order: "flags")

      expect(flagged_comment.body).to appear_before(flagged_new_comment.body)
      expect(flagged_new_comment.body).to appear_before(newer_comment.body)
    end
  end
end
