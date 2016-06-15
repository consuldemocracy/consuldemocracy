class ApplicationMailer < ActionMailer::Base
  helper :settings
  default from: "Decide Madrid <no-reply@madrid.es>"
  layout 'mailer'
end
