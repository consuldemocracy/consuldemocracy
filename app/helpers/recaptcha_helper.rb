module RecaptchaHelper

  def recaptchable?
    @debate.new_record?
  end
  
  def recaptcha_keys?
    Recaptcha.configuration.public_key.present? && 
    Recaptcha.configuration.private_key.present?
  end

end