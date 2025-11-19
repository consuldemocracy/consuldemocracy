require "rails_helper"

describe "Admin activity" do
  let(:admin) { create(:administrator, user: create(:user, username: "Admin Smith")) }

  before do
    login_as(admin.user)
  end

  context "Proposals" do
    scenario "Shows moderation activity on proposals" do
      proposal = create(:proposal, description: "<p>Description with html tag</p>", title: "Sample proposal")

      visit proposal_path(proposal)

      accept_confirm('Are you sure? Hide "Sample proposal"') { click_button "Hide" }

      expect(page).to have_css "#proposal_#{proposal.id}.faded"

      visit admin_activity_path(filter: "on_proposals")

      within "tbody tr" do
        expect(page).to have_content "Sample proposal"
        expect(page).to have_content "Hidden"
        expect(page).to have_content "Admin Smith"
        expect(page).to have_css "p", exact_text: "Description with html tag"
      end
    end

    scenario "Shows moderation activity from moderation screen" do
      create(:proposal, title: "Sample proposal 1")
      create(:proposal, title: "Sample proposal 2")
      create(:proposal, title: "Sample proposal 3")

      visit moderation_proposals_path(filter: "all")

      check "Sample proposal 1"
      check "Sample proposal 3"
      accept_confirm("Are you sure? Hide proposals") { click_button "Hide proposals" }

      expect(page).not_to have_content "Sample proposal 1"

      visit admin_activity_path(filter: "on_proposals")

      expect(page).to have_content "Sample proposal 1"
      expect(page).not_to have_content "Sample proposal 2"
      expect(page).to have_content "Sample proposal 3"
    end

    scenario "Shows admin restores" do
      create(:proposal, :hidden, title: "Sample proposal")

      visit admin_hidden_proposals_path

      accept_confirm("Are you sure? Restore") { click_button "Restore" }

      expect(page).to have_content "There are no hidden proposals"

      visit admin_activity_path(filter: "on_proposals")

      within "tbody tr" do
        expect(page).to have_content "Sample proposal"
        expect(page).to have_content "Restored"
        expect(page).to have_content "Admin Smith"
      end
    end
  end

  context "Debates" do
    scenario "Shows moderation activity on debates" do
      debate = create(:debate, title: "Sample debate")

      visit debate_path(debate)

      accept_confirm('Are you sure? Hide "Sample debate"') { click_button "Hide" }

      expect(page).to have_css "#debate_#{debate.id}.faded"

      visit admin_activity_path(filter: "on_debates")

      within "tbody tr" do
        expect(page).to have_content "Sample debate"
        expect(page).to have_content "Hidden"
        expect(page).to have_content "Admin Smith"
      end
    end

    scenario "Shows moderation activity from moderation screen" do
      create(:debate, title: "Sample debate 1")
      create(:debate, title: "Sample debate 2")
      create(:debate, title: "Sample debate 3")

      visit moderation_debates_path(filter: "all")

      check "Sample debate 1"
      check "Sample debate 3"
      accept_confirm("Are you sure? Hide debates") { click_button "Hide debates" }

      expect(page).not_to have_content "Sample debate 1"

      visit admin_activity_path(filter: "on_debates")

      expect(page).to have_content "Sample debate 1"
      expect(page).not_to have_content "Sample debate 2"
      expect(page).to have_content "Sample debate 3"
    end

    scenario "Shows admin restores" do
      create(:debate, :hidden, title: "Sample debate")

      visit admin_hidden_debates_path

      accept_confirm("Are you sure? Restore") { click_button "Restore" }

      expect(page).to have_content "There are no hidden debates"

      visit admin_activity_path(filter: "on_debates")

      within "tbody tr" do
        expect(page).to have_content "Sample debate"
        expect(page).to have_content "Restored"
        expect(page).to have_content "Admin Smith"
      end
    end
  end

  context "Comments" do
    scenario "Shows moderation activity on comments" do
      debate = create(:debate)
      comment = create(:comment, commentable: debate, body: "Sample comment")

      visit debate_path(debate)

      within "#comment_#{comment.id}" do
        accept_confirm('Are you sure? Hide "Sample comment"') { click_button "Hide" }
        expect(page).to have_css ".faded"
      end

      visit admin_activity_path(filter: "on_comments")

      within "tbody tr" do
        expect(page).to have_content "Sample comment"
        expect(page).to have_content "Hidden"
        expect(page).to have_content "Admin Smith"
      end
    end

    scenario "Shows moderation activity from moderation screen" do
      comment1 = create(:comment, body: "SPAM")
      create(:comment, body: "Not Spam")
      comment3 = create(:comment, body: "Offensive!")

      visit moderation_comments_path(filter: "all")

      check "comment_#{comment1.id}_check"
      check "comment_#{comment3.id}_check"
      accept_confirm("Are you sure? Hide comments") { click_button "Hide comments" }

      expect(page).not_to have_content "SPAM"

      visit admin_activity_path(filter: "on_comments")

      expect(page).to have_content "SPAM"
      expect(page).not_to have_content "Not Spam"
      expect(page).to have_content "Offensive!"
    end

    scenario "Shows admin restores" do
      create(:comment, :hidden, body: "Sample comment")

      visit admin_hidden_comments_path

      accept_confirm("Are you sure? Restore") { click_button "Restore" }

      expect(page).to have_content "There are no hidden comments"

      visit admin_activity_path(filter: "on_comments")

      within "tbody tr" do
        expect(page).to have_content "Sample comment"
        expect(page).to have_content "Restored"
        expect(page).to have_content "Admin Smith"
      end
    end
  end

  context "User" do
    scenario "Shows moderation activity on users" do
      proposal = create(:proposal, author: create(:user, username: "Sam", email: "sam@example.com"))

      visit proposal_path(proposal)

      accept_confirm('Are you sure? This will hide the user "Sam" and all their contents.') do
        click_button "Block author"
      end

      expect(page).to have_current_path proposals_path

      visit admin_activity_path(filter: "on_users")

      within "tbody tr" do
        expect(page).to have_content("Blocked")
        expect(page).to have_content "Sam"
        expect(page).to have_content "sam@example.com"
        expect(page).to have_content "Admin Smith"
        expect(page).not_to have_content proposal.title
      end
    end

    scenario "Shows moderation activity from moderation screen" do
      create(:user, username: "Sam", email: "sam@example.com")

      visit moderation_users_path(search: "Sam")

      accept_confirm { click_button "Block" }

      expect(page).to have_content "The user has been blocked"

      visit admin_activity_path(filter: "on_users")

      within "tbody tr" do
        expect(page).to have_content "Sam"
        expect(page).to have_content "sam@example.com"
        expect(page).to have_content "Admin Smith"
      end
    end

    scenario "Shows moderation activity from proposals moderation screen" do
      proposal1 = create(:proposal, title: "Sample proposal 1")
      proposal2 = create(:proposal, title: "Sample proposal 2")
      proposal3 = create(:proposal, title: "Sample proposal 3")

      visit moderation_proposals_path(filter: "all")

      check "Sample proposal 1"
      check "Sample proposal 3"

      accept_confirm("Are you sure? Block authors") { click_button "Block authors" }

      expect(page).not_to have_content "Sample proposal 1"

      visit admin_activity_path(filter: "on_users")

      expect(page).to have_content proposal1.author.username
      expect(page).to have_content proposal1.author.email
      expect(page).to have_content proposal3.author.username
      expect(page).to have_content proposal3.author.email
      expect(page).not_to have_content proposal2.author.username
    end

    scenario "Shows moderation activity from debates moderation screen" do
      debate1 = create(:debate, title: "Sample debate 1")
      debate2 = create(:debate, title: "Sample debate 2")
      debate3 = create(:debate, title: "Sample debate 3")

      visit moderation_debates_path(filter: "all")

      check "Sample debate 1"
      check "Sample debate 3"

      accept_confirm("Are you sure? Block authors") { click_button "Block authors" }

      expect(page).not_to have_content debate1.author.username

      visit admin_activity_path

      expect(page).to have_content debate1.author.username
      expect(page).to have_content debate1.author.email
      expect(page).to have_content debate3.author.username
      expect(page).to have_content debate3.author.email
      expect(page).not_to have_content debate2.author.username
    end

    scenario "Shows moderation activity from comments moderation screen" do
      comment1 = create(:comment)
      comment2 = create(:comment)
      comment3 = create(:comment)

      visit moderation_comments_path(filter: "all")

      check "comment_#{comment1.id}_check"
      check "comment_#{comment3.id}_check"

      accept_confirm("Are you sure? Block authors") { click_button "Block authors" }

      expect(page).not_to have_content comment1.author.username

      visit admin_activity_path

      expect(page).to have_content comment1.author.username
      expect(page).to have_content comment1.author.email
      expect(page).to have_content comment3.author.username
      expect(page).to have_content comment3.author.email
      expect(page).not_to have_content comment2.author.username
    end

    scenario "Shows admin restores" do
      create(:user, :hidden, username: "Sam", email: "sam@example.com")

      visit admin_hidden_users_path

      accept_confirm("Are you sure? Restore") { click_button "Restore" }

      expect(page).to have_content "There are no hidden users"

      visit admin_activity_path(filter: "on_users")

      within "tbody tr" do
        expect(page).to have_content "Sam"
        expect(page).to have_content "sam@example.com"
        expect(page).to have_content "Restored"
        expect(page).to have_content "Admin Smith"
      end
    end
  end

  context "System emails" do
    scenario "Shows moderation activity on system emails" do
      proposal = create(:proposal, title: "Proposal A")
      proposal_notification = create(:proposal_notification, proposal: proposal,
                                                             title: "Proposal A Title",
                                                             body: "Proposal A Notification Body")
      proposal_notification.moderate_system_email(admin.user)

      visit admin_activity_path(filter: "on_system_emails")

      within "tbody tr" do
        expect(page).to have_content "Proposal A Title"
        expect(page).to have_content "Hidden"
        expect(page).to have_content "Admin Smith"
      end
    end
  end

  context "Budget investments" do
    scenario "Shows moderation activity on budget investments" do
      investment = create(:budget_investment, title: "Sample investment")

      visit budget_investment_path(investment.budget, investment)

      accept_confirm('Are you sure? Hide "Sample investment"') { click_button "Hide" }

      expect(page).to have_css "#budget_investment_#{investment.id}.faded"

      visit admin_activity_path(filter: "on_budget_investments")

      within "tbody tr" do
        expect(page).to have_content "Sample investment"
        expect(page).to have_content "Hidden"
        expect(page).to have_content "Admin Smith"
      end
    end

    scenario "Shows moderation activity from moderation screen" do
      create(:budget_investment, title: "Sample investment 1")
      create(:budget_investment, title: "Sample investment 2")
      create(:budget_investment, title: "Sample investment 3")

      visit moderation_budget_investments_path(filter: "all")

      check "Sample investment 1"
      check "Sample investment 3"
      accept_confirm("Are you sure? Hide budget investments") { click_button "Hide budget investments" }

      expect(page).not_to have_content "Sample investment 1"

      visit admin_activity_path(filter: "on_budget_investments")

      expect(page).to have_content "Sample investment 1"
      expect(page).not_to have_content "Sample investment 2"
      expect(page).to have_content "Sample investment 3"
    end

    scenario "Shows admin restores" do
      create(:budget_investment, :hidden, title: "Sample investment")

      visit admin_hidden_budget_investments_path

      accept_confirm("Are you sure? Restore") { click_button "Restore" }

      expect(page).to have_content "There are no hidden budget investments"

      visit admin_activity_path(filter: "on_budget_investments")

      within "tbody tr" do
        expect(page).to have_content "Sample investment"
        expect(page).to have_content "Restored"
        expect(page).to have_content "Admin Smith"
      end
    end
  end
end
