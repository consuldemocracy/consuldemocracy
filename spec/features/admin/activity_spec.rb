require 'rails_helper'

feature 'Admin activity' do

  background do
    @admin = create(:administrator)
    login_as(@admin.user)
  end

  context "Proposals" do
    scenario "Shows moderation activity on proposals", :js do
      proposal = create(:proposal)

      visit proposal_path(proposal)

      within("#proposal_#{proposal.id}") do
        accept_confirm { click_link 'Hide' }
      end

      visit admin_activity_path

      within("#activity_#{Activity.last.id}") do
        expect(page).to have_content(proposal.title)
        expect(page).to have_content("Hidden")
        expect(page).to have_content(@admin.user.username)
      end
    end

    scenario "Shows moderation activity from moderation screen" do
      proposal1 = create(:proposal)
      proposal2 = create(:proposal)
      proposal3 = create(:proposal)

      visit moderation_proposals_path(filter: 'all')

      within("#proposal_#{proposal1.id}") do
        check "proposal_#{proposal1.id}_check"
      end

      within("#proposal_#{proposal3.id}") do
        check "proposal_#{proposal3.id}_check"
      end

      click_on "Hide proposals"

      visit admin_activity_path

      expect(page).to have_content(proposal1.title)
      expect(page).not_to have_content(proposal2.title)
      expect(page).to have_content(proposal3.title)
    end

    scenario "Shows admin restores" do
      proposal = create(:proposal, :hidden)

      visit admin_proposals_path

      within("#proposal_#{proposal.id}") do
        click_on "Restore"
      end

      visit admin_activity_path

      within("#activity_#{Activity.last.id}") do
        expect(page).to have_content(proposal.title)
        expect(page).to have_content("Restored")
        expect(page).to have_content(@admin.user.username)
      end
    end
  end

  context "Debates" do
    scenario "Shows moderation activity on debates", :js do
      debate = create(:debate)

      visit debate_path(debate)

      within("#debate_#{debate.id}") do
        accept_confirm { click_link 'Hide' }
      end

      visit admin_activity_path

      within("#activity_#{Activity.last.id}") do
        expect(page).to have_content(debate.title)
        expect(page).to have_content("Hidden")
        expect(page).to have_content(@admin.user.username)
      end
    end

    scenario "Shows moderation activity from moderation screen" do
      debate1 = create(:debate)
      debate2 = create(:debate)
      debate3 = create(:debate)

      visit moderation_debates_path(filter: 'all')

      within("#debate_#{debate1.id}") do
        check "debate_#{debate1.id}_check"
      end

      within("#debate_#{debate3.id}") do
        check "debate_#{debate3.id}_check"
      end

      click_on "Hide debates"

      visit admin_activity_path

      expect(page).to have_content(debate1.title)
      expect(page).not_to have_content(debate2.title)
      expect(page).to have_content(debate3.title)
    end

    scenario "Shows admin restores" do
      debate = create(:debate, :hidden)

      visit admin_debates_path

      within("#debate_#{debate.id}") do
        click_on "Restore"
      end

      visit admin_activity_path

      within("#activity_#{Activity.last.id}") do
        expect(page).to have_content(debate.title)
        expect(page).to have_content("Restored")
        expect(page).to have_content(@admin.user.username)
      end
    end
  end

  context "Comments" do
    scenario "Shows moderation activity on comments", :js do
      debate = create(:debate)
      comment = create(:comment, commentable: debate)

      visit debate_path(debate)

      within("#comment_#{comment.id}") do
        accept_confirm { click_link 'Hide' }
      end

      visit admin_activity_path

      within("#activity_#{Activity.last.id}") do
        expect(page).to have_content(comment.body)
        expect(page).to have_content("Hidden")
        expect(page).to have_content(@admin.user.username)
      end
    end

    scenario "Shows moderation activity from moderation screen" do
      comment1 = create(:comment, body: "SPAM")
      comment2 = create(:comment)
      comment3 = create(:comment, body: "Offensive!")

      visit moderation_comments_path(filter: 'all')

      within("#comment_#{comment1.id}") do
        check "comment_#{comment1.id}_check"
      end

      within("#comment_#{comment3.id}") do
        check "comment_#{comment3.id}_check"
      end

      click_on "Hide comments"

      visit admin_activity_path

      expect(page).to have_content(comment1.body)
      expect(page).not_to have_content(comment2.body)
      expect(page).to have_content(comment3.body)
    end

    scenario "Shows admin restores" do
      comment = create(:comment, :hidden)

      visit admin_comments_path

      within("#comment_#{comment.id}") do
        click_on "Restore"
      end

      visit admin_activity_path

      within("#activity_#{Activity.last.id}") do
        expect(page).to have_content(comment.body)
        expect(page).to have_content("Restored")
        expect(page).to have_content(@admin.user.username)
      end
    end
  end

  context "User" do
    scenario "Shows moderation activity on users" do
      proposal = create(:proposal)

      visit proposal_path(proposal)

      within("#proposal_#{proposal.id}") do
        click_link 'Hide author'
      end

      visit admin_activity_path

      within("#activity_#{Activity.last.id}") do
        expect(page).to have_content("Blocked")
        expect(page).to have_content(proposal.author.username)
        expect(page).to have_content(proposal.author.email)
        expect(page).to have_content(@admin.user.username)
        expect(page).not_to have_content(proposal.title)
      end
    end

    scenario "Shows moderation activity from moderation screen" do
      user = create(:user)

      visit moderation_users_path(name_or_email: user.username)

      within("#moderation_users") do
        click_link 'Block'
      end

      visit admin_activity_path

      within("#activity_#{Activity.last.id}") do
        expect(page).to have_content(user.username)
        expect(page).to have_content(user.email)
        expect(page).to have_content(@admin.user.username)
      end
    end

    scenario "Shows moderation activity from proposals moderation screen" do
      proposal1 = create(:proposal)
      proposal2 = create(:proposal)
      proposal3 = create(:proposal)

      visit moderation_proposals_path(filter: 'all')

      within("#proposal_#{proposal1.id}") do
        check "proposal_#{proposal1.id}_check"
      end

      within("#proposal_#{proposal3.id}") do
        check "proposal_#{proposal3.id}_check"
      end

      click_on "Block authors"

      visit admin_activity_path

      expect(page).to have_content(proposal1.author.username)
      expect(page).to have_content(proposal1.author.email)
      expect(page).to have_content(proposal3.author.username)
      expect(page).to have_content(proposal3.author.email)
      expect(page).not_to have_content(proposal2.author.username)
    end

    scenario "Shows moderation activity from debates moderation screen" do
      debate1 = create(:debate)
      debate2 = create(:debate)
      debate3 = create(:debate)

      visit moderation_debates_path(filter: 'all')

      within("#debate_#{debate1.id}") do
        check "debate_#{debate1.id}_check"
      end

      within("#debate_#{debate3.id}") do
        check "debate_#{debate3.id}_check"
      end

      click_on "Block authors"

      visit admin_activity_path

      expect(page).to have_content(debate1.author.username)
      expect(page).to have_content(debate1.author.email)
      expect(page).to have_content(debate3.author.username)
      expect(page).to have_content(debate3.author.email)
      expect(page).not_to have_content(debate2.author.username)
    end

    scenario "Shows moderation activity from comments moderation screen" do
      comment1 = create(:comment, body: "SPAM")
      comment2 = create(:comment)
      comment3 = create(:comment, body: "Offensive!")

      visit moderation_comments_path(filter: 'all')

      within("#comment_#{comment1.id}") do
        check "comment_#{comment1.id}_check"
      end

      within("#comment_#{comment3.id}") do
        check "comment_#{comment3.id}_check"
      end

      click_on "Block authors"

      visit admin_activity_path

      expect(page).to have_content(comment1.author.username)
      expect(page).to have_content(comment1.author.email)
      expect(page).to have_content(comment3.author.username)
      expect(page).to have_content(comment3.author.email)
      expect(page).not_to have_content(comment2.author.username)
    end

    scenario "Shows admin restores" do
      user = create(:user, :hidden)

      visit admin_hidden_users_path

      within("#user_#{user.id}") do
        click_on "Restore"
      end

      visit admin_activity_path

      within("#activity_#{Activity.last.id}") do
        expect(page).to have_content(user.username)
        expect(page).to have_content(user.email)
        expect(page).to have_content("Restored")
        expect(page).to have_content(@admin.user.username)
      end
    end
  end

  context "System emails" do
    scenario "Shows moderation activity on system emails" do
      proposal = create(:proposal, title: 'Proposal A')
      proposal_notification = create(:proposal_notification, proposal: proposal,
                                                               title: 'Proposal A Title',
                                                               body: 'Proposal A Notification Body')
      proposal_notification.moderate_system_email(@admin.user)

      visit admin_activity_path

      within("#activity_#{Activity.last.id}") do
        expect(page).to have_content(proposal_notification.title)
        expect(page).to have_content("Hidden")
        expect(page).to have_content(@admin.user.username)
      end
    end
  end

end
