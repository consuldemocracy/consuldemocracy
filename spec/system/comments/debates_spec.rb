require "rails_helper"

describe "Commenting debates" do
  let(:user)   { create(:user) }
  let(:debate) { create(:debate) }

  it_behaves_like "flaggable", :debate_comment

  scenario "can collapse comments after adding a reply" do
    create(:comment, body: "Main comment", commentable: debate)

    login_as(user)
    visit debate_path(debate)

    within ".comment", text: "Main comment" do
      first(:link, "Reply").click
      fill_in "Leave your comment", with: "It will be done next week."
      click_button "Publish reply"

      expect(page).to have_content("It will be done next week.")

      click_link text: "1 response (collapse)"

      expect(page).not_to have_content("It will be done next week.")
    end
  end

  scenario "Create" do
    login_as(user)
    visit debate_path(debate)

    fill_in "Leave your comment", with: "Have you thought about...?"
    click_button "Publish comment"

    within "#comments" do
      expect(page).to have_content "Have you thought about...?"
      expect(page).to have_content "(1)"
    end
  end

  describe "Hide" do
    scenario "Without replies" do
      create(:comment, commentable: debate, user: user, body: "This was a mistake")

      login_as(user)
      visit debate_path(debate)

      accept_confirm("Are you sure? This action will delete this comment. You can't undo this action.") do
        within(".comment-body", text: "This was a mistake") { click_link "Delete comment" }
      end

      expect(page).not_to have_content "This was a mistake"
      expect(page).not_to have_link "Delete comment"

      visit debate_path(debate)

      expect(page).not_to have_content "This was a mistake"
      expect(page).not_to have_link "Delete comment"

      logout
      login_as(create(:administrator).user)

      visit admin_hidden_comments_path

      expect(page).to have_content "This was a mistake"
    end

    scenario "With replies" do
      comment = create(:comment, commentable: debate, user: user, body: "Wrong comment")
      create(:comment, commentable: debate, parent: comment, body: "Right reply")

      login_as(user)
      visit debate_path(debate)

      accept_confirm("Are you sure? This action will delete this comment. You can't undo this action.") do
        within(".comment-body", text: "Wrong comment") { click_link "Delete comment" }
      end

      within "#comments > .comment-list > li", text: "Right reply" do
        expect(page).to have_content "This comment has been deleted"
        expect(page).not_to have_content "Wrong comment"
      end

      visit debate_path(debate)

      within "#comments > .comment-list > li", text: "Right reply" do
        expect(page).to have_content "This comment has been deleted"
        expect(page).not_to have_content "Wrong comment"
      end
    end
  end

  scenario "Reply" do
    citizen = create(:user, username: "Ana")
    manuela = create(:user, username: "Manuela")
    comment = create(:comment, commentable: debate, user: citizen)

    login_as(manuela)
    visit debate_path(debate)

    click_link "Reply"

    within "#js-comment-form-comment_#{comment.id}" do
      fill_in "Leave your comment", with: "It will be done next week."
      click_button "Publish reply"
    end

    within "#comment_#{comment.id}" do
      expect(page).to have_content "It will be done next week."
    end

    expect(page).not_to have_css "#js-comment-form-comment_#{comment.id}"
  end

  scenario "Reply to reply" do
    create(:comment, commentable: debate, body: "Any estimates?")

    login_as(create(:user))
    visit debate_path(debate)

    within ".comment", text: "Any estimates?" do
      click_link "Reply"
      fill_in "Leave your comment", with: "It will be done next week."
      click_button "Publish reply"
    end

    within ".comment .comment", text: "It will be done next week" do
      click_link "Reply"
      fill_in "Leave your comment", with: "Probably if government approves."
      click_button "Publish reply"

      expect(page).not_to have_css ".comment-form"

      within ".comment" do
        expect(page).to have_content "Probably if government approves."
      end
    end
  end

  scenario "Reply update parent comment responses count" do
    comment = create(:comment, commentable: debate)

    login_as(create(:user))
    visit debate_path(debate)

    within ".comment", text: comment.body do
      click_link "Reply"
      fill_in "Leave your comment", with: "It will be done next week."
      click_button "Publish reply"

      expect(page).to have_content("1 response (collapse)")
    end
  end

  scenario "Reply show parent comments responses when hidden" do
    comment = create(:comment, commentable: debate)
    create(:comment, commentable: debate, parent: comment)

    login_as(create(:user))
    visit debate_path(debate)

    within ".comment", text: comment.body do
      click_link text: "1 response (collapse)"
      click_link "Reply"
      fill_in "Leave your comment", with: "It will be done next week."
      click_button "Publish reply"

      expect(page).to have_content("It will be done next week.")
    end
  end

  scenario "Show comment when the author is hidden" do
    create(:comment, body: "This is pointless", commentable: debate, author: create(:user, :hidden))

    visit debate_path(debate)

    within ".comment", text: "This is pointless" do
      expect(page).to have_content "User deleted"
    end
  end

  scenario "Errors on reply" do
    comment = create(:comment, commentable: debate, user: user)

    login_as(user)
    visit debate_path(debate)

    click_link "Reply"

    within "#js-comment-form-comment_#{comment.id}" do
      click_button "Publish reply"
      expect(page).to have_content "Can't be blank"
    end
  end

  scenario "N replies" do
    parent = create(:comment, commentable: debate)

    7.times do
      create(:comment, commentable: debate, parent: parent)
      parent = parent.children.first
    end

    visit debate_path(debate)
    expect(page).to have_css(".comment.comment.comment.comment.comment.comment.comment.comment")
  end

  scenario "Erasing a comment's author" do
    debate = create(:debate)
    comment = create(:comment, commentable: debate, body: "this should be visible")
    comment.user.erase

    visit debate_path(debate)
    within "#comment_#{comment.id}" do
      expect(page).to have_content("User deleted")
      expect(page).to have_content("this should be visible")
    end
  end

  scenario "Submit button is disabled after clicking" do
    debate = create(:debate)
    login_as(user)
    visit debate_path(debate)

    fill_in "Leave your comment", with: "Testing submit button!"
    click_button "Publish comment"

    expect(page).to have_button "Publish comment", disabled: true
    expect(page).to have_content "Testing submit button!"
    expect(page).to have_button "Publish comment", disabled: false
  end

  describe "Moderators" do
    scenario "can create comment as a moderator" do
      moderator = create(:moderator)

      login_as(moderator.user)
      visit debate_path(debate)

      fill_in "Leave your comment", with: "I am moderating!"
      check "comment-as-moderator-debate_#{debate.id}"
      click_button "Publish comment"

      within "#comments" do
        expect(page).to have_content "I am moderating!"
        expect(page).to have_content "Moderator ##{moderator.id}"
        expect(page).to have_css "div.is-moderator"
        expect(page).to have_css "img.moderator-avatar"
      end
    end

    scenario "can create reply as a moderator" do
      citizen = create(:user, username: "Ana")
      manuela = create(:user, username: "Manuela")
      moderator = create(:moderator, user: manuela)
      comment = create(:comment, commentable: debate, user: citizen)

      login_as(manuela)
      visit debate_path(debate)

      click_link "Reply"

      within "#js-comment-form-comment_#{comment.id}" do
        fill_in "Leave your comment", with: "I am moderating!"
        check "comment-as-moderator-comment_#{comment.id}"
        click_button "Publish reply"
      end

      within "#comment_#{comment.id}" do
        expect(page).to have_content "I am moderating!"
        expect(page).to have_content "Moderator ##{moderator.id}"
        expect(page).to have_css "div.is-moderator"
        expect(page).to have_css "img.moderator-avatar"
      end

      expect(page).not_to have_css "#js-comment-form-comment_#{comment.id}"
    end

    scenario "can not comment as an administrator" do
      moderator = create(:moderator)

      login_as(moderator.user)
      visit debate_path(debate)

      expect(page).not_to have_content "Comment as administrator"
    end
  end

  describe "Administrators" do
    scenario "can create comment as an administrator" do
      admin = create(:administrator)

      login_as(admin.user)
      visit debate_path(debate)

      fill_in "Leave your comment", with: "I am your Admin!"
      check "comment-as-administrator-debate_#{debate.id}"
      click_button "Publish comment"

      within "#comments" do
        expect(page).to have_content "I am your Admin!"
        expect(page).to have_content "Administrator ##{admin.id}"
        expect(page).to have_css "div.is-admin"
        expect(page).to have_css "img.admin-avatar"
      end
    end

    scenario "can create reply as an administrator" do
      citizen = create(:user, username: "Ana")
      manuela = create(:user, username: "Manuela")
      admin   = create(:administrator, user: manuela)
      comment = create(:comment, commentable: debate, user: citizen)

      login_as(manuela)
      visit debate_path(debate)

      click_link "Reply"

      within "#js-comment-form-comment_#{comment.id}" do
        fill_in "Leave your comment", with: "Top of the world!"
        check "comment-as-administrator-comment_#{comment.id}"
        click_button "Publish reply"
      end

      within "#comment_#{comment.id}" do
        expect(page).to have_content "Top of the world!"
        expect(page).to have_content "Administrator ##{admin.id}"
        expect(page).to have_css "div.is-admin"
        expect(page).to have_css "img.admin-avatar"
      end

      expect(page).not_to have_css "#js-comment-form-comment_#{comment.id}"
    end

    scenario "can not comment as a moderator", :admin do
      visit debate_path(debate)

      expect(page).not_to have_content "Comment as moderator"
    end
  end

  describe "Voting comments" do
    let(:verified)   { create(:user, verified_at: Time.current) }
    let(:unverified) { create(:user) }
    let(:debate)     { create(:debate) }
    let!(:comment)   { create(:comment, commentable: debate) }

    before do
      login_as(verified)
    end

    scenario "Show" do
      create(:vote, voter: verified, votable: comment, vote_flag: true)
      create(:vote, voter: unverified, votable: comment, vote_flag: false)

      visit debate_path(debate)

      within("#comment_#{comment.id}_votes") do
        within(".in-favor") do
          expect(page).to have_content "1"
        end

        within(".against") do
          expect(page).to have_content "1"
        end

        expect(page).to have_content "2 votes"
      end
    end

    scenario "Create" do
      visit debate_path(debate)

      within("#comment_#{comment.id}_votes") do
        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "1"
        end

        within(".against") do
          expect(page).to have_content "0"
        end

        expect(page).to have_content "1 vote"
      end
    end

    scenario "Update" do
      visit debate_path(debate)

      within("#comment_#{comment.id}_votes") do
        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "1"
        end

        click_button "I disagree"

        within(".in-favor") do
          expect(page).to have_content "0"
        end

        within(".against") do
          expect(page).to have_content "1"
        end

        expect(page).to have_content "1 vote"
      end
    end

    scenario "Allow undoing votes" do
      visit debate_path(debate)

      within("#comment_#{comment.id}_votes") do
        click_button "I agree"
        within(".in-favor") do
          expect(page).to have_content "1"
        end

        click_button "I agree"
        within(".in-favor") do
          expect(page).not_to have_content "2"
          expect(page).to have_content "0"
        end

        within(".against") do
          expect(page).to have_content "0"
        end

        expect(page).to have_content "No votes"
      end
    end
  end
end
