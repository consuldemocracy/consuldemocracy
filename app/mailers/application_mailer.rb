class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.secrets.mail_from
  layout 'mailer'
end
