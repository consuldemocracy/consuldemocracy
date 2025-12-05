class DeviseMailer < Devise::Mailer
  helper :application, :settings
  include Devise::Controllers::UrlHelpers
  default template_path: "devise/mailer"

  def confirmation_instructions(record, token, opts = {})
    @token = token
    
    Rails.logger.info "====== CONFIRMATION INSTRUCTIONS ======"
    Rails.logger.info "Record class: #{record.class.name}"
    Rails.logger.info "Es organización?: #{record.organization?}"
    
    # Usa el método name del modelo User que ya maneja esto
    display_name = record.name.presence || record.email
    
    Rails.logger.info "Display name: #{display_name}"
    
    opts[:subject] = I18n.t(
      'devise.mailer.confirmation_instructions.subject',
      name: display_name
    )
    
    Rails.logger.info "Subject generado: #{opts[:subject]}"
    Rails.logger.info "======================================="
    
    super(record, token, opts)
  end

  protected

    def devise_mail(record, action, opts = {})
      I18n.with_locale record.locale do
        super(record, action, opts)
      end
    end

end