require 'rails_helper'

feature 'Emails' do

  background do
    reset_mailer
  end

  scenario "Signup Email" do
    sign_up

    email = open_last_email
    expect(email).to have_subject('Confirmation instructions')
    expect(email).to deliver_to('manuela@madrid.es')
    expect(email).to have_body_text(user_confirmation_path)
  end

  scenario "Reset password" do
    reset_password

    email = open_last_email
    expect(email).to have_subject('Instructions for resetting your password')
    expect(email).to deliver_to('manuela@madrid.es')
    expect(email).to have_body_text(edit_user_password_path)
  end

  context 'Proposal comments' do
    scenario "Send email on proposal comment", :js do
      user = create(:user, email_on_comment: true)
      proposal = create(:proposal, author: user)
      comment_on(proposal)

      email = open_last_email
      expect(email).to have_subject('Someone has commented on your citizen proposal')
      expect(email).to deliver_to(proposal.author)
      expect(email).to have_body_text(proposal_path(proposal))
    end

    scenario 'Do not send email about own proposal comments', :js do
      user = create(:user, email_on_comment: true)
      proposal = create(:proposal, author: user)
      comment_on(proposal, user)

      expect { open_last_email }.to raise_error "No email has been sent!"
    end

    scenario 'Do not send email about proposal comment unless set in preferences', :js do
      user = create(:user, email_on_comment: false)
      proposal = create(:proposal, author: user)
      comment_on(proposal)

      expect { open_last_email }.to raise_error "No email has been sent!"
    end
  end

  context 'Debate comments' do
    scenario "Send email on debate comment", :js do
      user = create(:user, email_on_comment: true)
      debate = create(:debate, author: user)
      comment_on(debate)

      email = open_last_email
      expect(email).to have_subject('Someone has commented on your debate')
      expect(email).to deliver_to(debate.author)
      expect(email).to have_body_text(debate_path(debate))
      expect(email).to have_body_text(I18n.t("mailers.config.manage_email_subscriptions"))
      expect(email).to have_body_text(account_path)
    end

    scenario 'Do not send email about own debate comments', :js do
      user = create(:user, email_on_comment: true)
      debate = create(:debate, author: user)
      comment_on(debate, user)

      expect { open_last_email }.to raise_error "No email has been sent!"
    end

    scenario 'Do not send email about debate comment unless set in preferences', :js do
      user = create(:user, email_on_comment: false)
      debate = create(:debate, author: user)
      comment_on(debate)

      expect { open_last_email }.to raise_error "No email has been sent!"
    end
  end

  context 'Comment replies' do
    scenario "Send email on comment reply", :js do
      user = create(:user, email_on_comment_reply: true)
      reply_to(user)

      email = open_last_email
      expect(email).to have_subject('Someone has responded to your comment')
      expect(email).to deliver_to(user)
      expect(email).to_not have_body_text(debate_path(Comment.first.commentable))
      expect(email).to have_body_text(comment_path(Comment.last))
      expect(email).to have_body_text(I18n.t("mailers.config.manage_email_subscriptions"))
      expect(email).to have_body_text(account_path)
    end

    scenario "Do not send email about own replies to own comments", :js do
      user = create(:user, email_on_comment_reply: true)
      reply_to(user, user)

      expect { open_last_email }.to raise_error "No email has been sent!"
    end

    scenario "Do not send email about comment reply unless set in preferences", :js do
      user = create(:user, email_on_comment_reply: false)
      reply_to(user)

      expect { open_last_email }.to raise_error "No email has been sent!"
    end
  end

  scenario "Email depending on user's locale" do
    sign_up

    email = open_last_email
    expect(email).to have_subject('Confirmation instructions')
    expect(email).to deliver_to('manuela@madrid.es')
    expect(email).to have_body_text(user_confirmation_path)
  end

  scenario "Email on unfeasible spending proposal" do
    spending_proposal = create(:spending_proposal)
    administrator = create(:administrator)
    valuator = create(:valuator)
    spending_proposal.update(administrator: administrator)
    spending_proposal.valuators << valuator

    login_as(valuator.user)
    visit edit_valuation_spending_proposal_path(spending_proposal)

    choose  'spending_proposal_feasible_false'
    fill_in 'spending_proposal_feasible_explanation', with: 'This is not legal as stated in Article 34.9'
    check 'spending_proposal_valuation_finished'
    click_button 'Save changes'

    expect(page).to have_content "Dossier updated"
    spending_proposal.reload

    email = open_last_email
    expect(email).to have_subject("Your investment project '#{spending_proposal.code}' has been marked as unfeasible")
    expect(email).to deliver_to(spending_proposal.author.email)
    expect(email).to have_body_text(spending_proposal.title)
    expect(email).to have_body_text(spending_proposal.code)
    expect(email).to have_body_text(spending_proposal.feasible_explanation)
  end

  context "Proposal notifications" do

    scenario "Proposal notification" do
      author = create(:user)

      noelia = create(:user)
      vega = create(:user)
      cristina = create(:user)

      proposal = create(:proposal, author: author)

      create(:vote, voter: noelia, votable: proposal, vote_flag: true)
      create(:vote, voter: vega,   votable: proposal, vote_flag: true)

      reset_mailer

      login_as(author)
      visit root_path

      visit new_proposal_notification_path(proposal_id: proposal.id)

      fill_in 'proposal_notification_title', with: "Thank you for supporting my proposal"
      fill_in 'proposal_notification_body', with: "Please share it with others so we can make it happen!"
      click_button "Send message"

      expect(page).to have_content "Your message has been sent correctly."

      expect(unread_emails_for(noelia.email).size).to   eql parse_email_count(1)
      expect(unread_emails_for(vega.email).size).to     eql parse_email_count(1)
      expect(unread_emails_for(cristina.email).size).to eql parse_email_count(0)
      expect(unread_emails_for(author.email).size).to   eql parse_email_count(0)

      email = open_last_email
      expect(email).to have_subject("Thank you for supporting my proposal")
      expect(email).to have_body_text("Please share it with others so we can make it happen!")
      expect(email).to have_body_text(proposal.title)
    end

    scenario "Do not send email about proposal notifications unless set in preferences", :js do
      author = create(:user)
      voter = create(:user, email_on_proposal_notification: false)

      proposal = create(:proposal)
      create(:vote, voter: voter, votable: proposal, vote_flag: true)

      login_as(author)
      visit new_proposal_notification_path(proposal_id: proposal.id)

      fill_in 'proposal_notification_title', with: "Thank you for supporting my proposal"
      fill_in 'proposal_notification_body', with: "Please share it with others so we can make it happen!"
      click_button "Send message"

      expect { open_last_email }.to raise_error "No email has been sent!"
    end
  end

end
