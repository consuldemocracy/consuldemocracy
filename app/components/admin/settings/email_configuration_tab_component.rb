class Admin::Settings::EmailConfigurationTabComponent < ApplicationComponent
  def tab
    "#tab-email-configuration"
  end

  def settings
    %w[
      mailer_from_name
      mailer_from_address
    ]
  end

  def smtp_settings
    %w[
      smtp.address
      smtp.port
      smtp.domain
      smtp.user_name
      smtp.password
      smtp.authentication
    ]
  end
end
