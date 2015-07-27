module RecaptchaHelper
  
  def recaptcha_keys?
    Recaptcha.configuration.public_key.present? && 
    Recaptcha.configuration.private_key.present?
  end

end