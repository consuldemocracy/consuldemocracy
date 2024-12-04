Warden::Manager.after_authentication do |user, auth, opts|
  if Rails.application.config.authentication_logs
    request = auth.request
    login = request.params.dig(opts[:scope].to_s, "login")
    message = "The user #{login} with IP address: #{request.ip} successfully signed in."
    AuthenticationLogger.log(message)
  end
end

Warden::Manager.before_failure do |env, opts|
  if Rails.application.config.authentication_logs
    request = Rack::Request.new(env)
    login = request.params.dig(opts[:scope].to_s, "login")
    message = "The user #{login} with IP address: #{request.ip} failed to sign in."
    AuthenticationLogger.log(message)

    user = User.find_by(username: login) || User.find_by(email: login)
    if user&.failed_attempts == User.maximum_attempts.to_i
      message = "The user #{login} with IP address: #{request.ip} reached maximum attempts " \
                "and it's temporarily locked."
      AuthenticationLogger.log(message)
    end
  end
end
