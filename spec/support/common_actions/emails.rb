module Emails
  def create_direct_message(sender, receiver)
    login_as(sender)
    visit user_path(receiver)

    click_link "Send private message"

    expect(page).to have_content "Send private message to #{receiver.name}"

    fill_in "direct_message_title", with: "Hey #{receiver.name}!"
    fill_in "direct_message_body",  with: "How are you doing? This is #{sender.name}"

    click_button "Send message"

    expect(page).to have_content "You message has been sent successfully."
    DirectMessage.last
  end

  def fill_in_newsletter_form(options = {})
    select (options[:segment_recipient] || "All users"), from: "Recipients"
    fill_in "Subject", with: (options[:subject] || "This is a different subject")
    fill_in "E-mail address that will appear as sending the newsletter",
            with: (options[:from] || "no-reply@consul.dev")
    fill_in_ckeditor "Email content", with: (options[:body] || "This is a different body")
  end
end
