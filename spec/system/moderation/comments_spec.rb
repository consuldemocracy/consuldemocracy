require "rails_helper"

describe "Moderate comments" do
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
end
