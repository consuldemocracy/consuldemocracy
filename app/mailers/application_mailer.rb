class ApplicationMailer < ActionMailer::Base
  helper :settings
  if !ActiveRecord::Base.connection.table_exists?('settings')
    default from: "noreply@consul.dev"
  else
    default from: "#{Setting['mailer_from_name']} <#{Setting['mailer_from_address']}>"
  end
  layout 'mailer'
end
