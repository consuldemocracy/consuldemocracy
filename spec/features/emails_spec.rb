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
      expect(email).to have_body_text(debate_path(Comment.first.commentable))
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

end
