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
    expect(email).to have_subject('Reset password instructions')
    expect(email).to deliver_to('manuela@madrid.es')
    expect(email).to have_body_text(edit_user_password_path)
  end

  scenario "Debate comment", :js do
    user = create(:user, email_on_debate_comment: true)
    debate = create(:debate, author: user)
    comment_on(debate)

    email = open_last_email
    expect(email).to have_subject('Someone has commented on your debate')
    expect(email).to deliver_to(debate.author)
    expect(email).to have_body_text(debate_path(debate))
  end

  scenario "Comment reply", :js do
    user = create(:user, email_on_comment_reply: true)
    reply_to(user)

    email = open_last_email
    expect(email).to have_subject('Someone has replied to your comment')
    expect(email).to deliver_to(user)
    expect(email).to have_body_text(debate_path(Comment.first.debate))
  end

  scenario 'Do not send email about debate comment unless set in preferences', :js do
    user = create(:user, email_on_debate_comment: false)
    debate = create(:debate, author: user)
    comment_on(debate)

    expect { open_last_email }.to raise_error "No email has been sent!"
  end

  scenario "Do not send email about comment reply unless set in preferences", :js do
    user = create(:user, email_on_comment_reply: false)
    reply_to(user)

    expect { open_last_email }.to raise_error "No email has been sent!"
  end

end