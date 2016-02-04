class ApplicationMailer < ActionMailer::Base
  helper :settings
  default from: "participacion@madrid.es"
  layout 'mailer'
end
