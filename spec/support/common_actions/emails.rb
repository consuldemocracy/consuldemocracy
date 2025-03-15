module Emails
  def fill_in_newsletter_form(options = {})
    select (options[:segment_recipient] || "All users"), from: "Recipients"
    fill_in "Subject", with: options[:subject] || "This is a different subject"
    fill_in "E-mail address that will appear as sending the newsletter",
            with: options[:from] || "no-reply@consul.dev"
    fill_in_ckeditor "Email content", with: options[:body] || "This is a different body"
  end
end
