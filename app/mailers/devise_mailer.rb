class DeviseMailer < Devise::Mailer
  helper :application, :settings
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'
  default from: "#{Setting["mailer_from_name"]} <#{Setting["mailer_from_address"]}>"
  default reply_to: "#{Setting["mailer_from_name"]} <#{Setting["mailer_from_address"]}>"

  protected

  def devise_mail(record, action, opts = {})
    I18n.with_locale record.locale do
      super(record, action, opts)
    end
  end
end
