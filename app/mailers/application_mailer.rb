class ApplicationMailer < ActionMailer::Base
  helper :settings
  helper :application
  helper :mailer
  default from: proc { "#{Setting["mailer_from_name"]} <#{Setting["mailer_from_address"]}>" }
  layout "mailer"
end
