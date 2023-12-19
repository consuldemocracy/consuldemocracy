require "rails_helper"

describe "Commenting legislation questions" do
  let(:user) { create(:user, :level_two) }
  let(:process) { create(:legislation_process, :in_debate_phase) }
  let(:question) { create(:legislation_question, process: process) }

  context "Concerns" do
    it_behaves_like "notifiable in-app", :legislation_question
    it_behaves_like "flaggable", :legislation_question_comment
  end

  scenario "Reply update parent comment responses count" do
    manuela = create(:user, :level_two, username: "Manuela")
    comment = create(:comment, commentable: question)

    login_as(manuela)
    visit legislation_process_question_path(question.process, question)

    within ".comment", text: comment.body do
      click_link "Reply"
      fill_in "Leave your answer", with: "It will be done next week."
      click_button "Publish reply"

      expect(page).to have_content("1 response (collapse)")
    end
  end

  scenario "Reply show parent comments responses when hidden" do
    manuela = create(:user, :level_two, username: "Manuela")
    comment = create(:comment, commentable: question)
    create(:comment, commentable: question, parent: comment)

    login_as(manuela)
    visit legislation_process_question_path(question.process, question)

    within ".comment", text: comment.body do
      click_link text: "1 response (collapse)"
      click_link "Reply"
      fill_in "Leave your answer", with: "It will be done next week."
      click_button "Publish reply"

      expect(page).to have_content("It will be done next week.")
    end
  end

  scenario "Errors on reply" do
    comment = create(:comment, commentable: question, user: user)

    login_as(user)
    visit legislation_process_question_path(question.process, question)

    click_link "Reply"

    within "#js-comment-form-comment_#{comment.id}" do
      click_button "Publish reply"
      expect(page).to have_content "Can't be blank"
    end
  end

  scenario "N replies" do
    parent = create(:comment, commentable: question)

    7.times do
      create(:comment, commentable: question, parent: parent)
      parent = parent.children.first
    end

    visit legislation_process_question_path(question.process, question)
    expect(page).to have_css(".comment.comment.comment.comment.comment.comment.comment.comment")
  end

  scenario "Erasing a comment's author" do
    comment = create(:comment, commentable: question, body: "this should be visible")
    comment.user.erase

    visit legislation_process_question_path(question.process, question)
    within "#comment_#{comment.id}" do
      expect(page).to have_content("User deleted")
      expect(page).to have_content("this should be visible")
    end
  end

  scenario "Submit button is disabled after clicking" do
    login_as(user)
    visit legislation_process_question_path(question.process, question)

    fill_in "Leave your answer", with: "Testing submit button!"
    click_button "Publish answer"

    expect(page).to have_button "Publish answer", disabled: true
    expect(page).to have_content "Testing submit button!"
    expect(page).to have_button "Publish answer", disabled: false
  end

  describe "Moderators" do
    scenario "can create comment as a moderator" do
      moderator = create(:moderator)

      login_as(moderator.user)
      visit legislation_process_question_path(question.process, question)

      fill_in "Leave your answer", with: "I am moderating!"
      check "comment-as-moderator-legislation_question_#{question.id}"
      click_button "Publish answer"

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
      comment = create(:comment, commentable: question, user: citizen)

      login_as(manuela)
      visit legislation_process_question_path(question.process, question)

      click_link "Reply"

      within "#js-comment-form-comment_#{comment.id}" do
        fill_in "Leave your answer", with: "I am moderating!"
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
      visit legislation_process_question_path(question.process, question)

      expect(page).not_to have_content "Comment as administrator"
    end
  end

  describe "Administrators" do
    scenario "can create comment as an administrator" do
      admin = create(:administrator)

      login_as(admin.user)
      visit legislation_process_question_path(question.process, question)

      fill_in "Leave your answer", with: "I am your Admin!"
      check "comment-as-administrator-legislation_question_#{question.id}"
      click_button "Publish answer"

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
      comment = create(:comment, commentable: question, user: citizen)

      login_as(manuela)
      visit legislation_process_question_path(question.process, question)

      click_link "Reply"

      within "#js-comment-form-comment_#{comment.id}" do
        fill_in "Leave your answer", with: "Top of the world!"
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
      visit legislation_process_question_path(question.process, question)

      expect(page).not_to have_content "Comment as moderator"
    end
  end

  describe "Voting comments" do
    let(:verified)   { create(:user, verified_at: Time.current) }
    let(:unverified) { create(:user) }
    let(:question)   { create(:legislation_question) }
    let!(:comment)   { create(:comment, commentable: question) }

    before do
      login_as(verified)
    end

    scenario "Show" do
      create(:vote, voter: verified, votable: comment, vote_flag: true)
      create(:vote, voter: unverified, votable: comment, vote_flag: false)

      visit legislation_process_question_path(question.process, question)

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
      visit legislation_process_question_path(question.process, question)

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
      visit legislation_process_question_path(question.process, question)

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
      visit legislation_process_question_path(question.process, question)

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
