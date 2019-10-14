class ApplicationMailer < ActionMailer::Base

  before_action :add_inline_attachment!
  helper :settings
  default from: "#{Setting['mailer_from_name']  || Setting['org_name']} <#{Setting['mailer_from_address']}>"
  layout 'mailer'

  private

  def add_inline_attachment!
    attachments.inline["logo_email.png"] = File.read(Rails.root.join('app/assets/images/logo_email.png'))
  end
end
