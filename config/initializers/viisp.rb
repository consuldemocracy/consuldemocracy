require 'viisp/auth'

VIISP::Auth.configure do |c|
  c.pid = 'VSID000000000113'
  c.private_key = OpenSSL::PKey::RSA.new(File.read('./config/keys/testKey.pem'))
  c.postback_url = 'http://212.24.109.28:3000/'

  # optional
  c.providers = %w[auth.lt.identity.card auth.lt.bank]
  c.attributes = %w[lt-personal-code lt-company-code]
  c.user_information = %w[firstName lastName companyName email]

  # enable test mode
  # (in test mode there is no need to set pid and private_key)
  c.test = true#Rails.env.test? # Adjust this condition based on your environment
end
