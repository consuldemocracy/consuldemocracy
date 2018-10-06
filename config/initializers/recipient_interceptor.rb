if (recipients = Rails.application.secrets.interceptor_recipients)
  interceptor = RecipientInterceptor.new(recipients)
  Mail.register_interceptor(interceptor)
end