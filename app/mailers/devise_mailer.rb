class DeviseMailer < Devise::Mailer
  helper :application, :settings, :mailer
  include Devise::Controllers::UrlHelpers
  default template_path: "devise/mailer"

  protected

    def devise_mail(record, action, opts = {})
      I18n.with_locale record.locale do
        super(record, action, opts)
      end
    end
end
