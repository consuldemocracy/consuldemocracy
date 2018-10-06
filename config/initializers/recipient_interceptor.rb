recipients = Rails.application.secrets.email_interceptor_recipients

if recipients.present?
  interceptor = RecipientInterceptor.new(recipients)
  Mail.register_interceptor(interceptor)
end
