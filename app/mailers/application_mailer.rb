class ApplicationMailer < ActionMailer::Base
  helper :settings
  default from: "#{Setting['mailer_from_name']} <#{Setting['mailer_from_address']}>"
  layout 'mailer'

  before_action :add_inline_attachment!

  def add_inline_attachment!
    attachments.inline["logo_email.png"] = File.read(Rails.root.join('app/assets/images/custom/logo_email.png'))
  end
end
