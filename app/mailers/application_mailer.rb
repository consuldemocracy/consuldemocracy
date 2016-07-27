class ApplicationMailer < ActionMailer::Base
  helper :settings
  default from: "Consul <no-reply@consul.es>"
  layout 'mailer'
end
