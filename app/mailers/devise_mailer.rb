class DeviseMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers

  default template_path: "devise/mailer"

  protected

    def devise_mail(record, action, opts = {})
      I18n.with_locale(record.locale) { super }
    end
end
