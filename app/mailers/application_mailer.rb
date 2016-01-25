class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic

  default from: "Decidim Barcelona <#{Rails.application.secrets.email}>"
  layout 'mailer'

  private

  def with_user(user, &block)
    I18n.with_locale(user.locale) do
      block.call
    end
  end
end
