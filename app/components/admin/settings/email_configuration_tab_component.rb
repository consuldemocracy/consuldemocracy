class Admin::Settings::EmailConfigurationTabComponent < ApplicationComponent
  def settings
    %w[
      mailer_from_name
      mailer_from_address
    ]
  end
end
