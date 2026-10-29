module RequestSpecHelper
  def sign_in(user)
    post user_session_path, params: { user: { login: user.email, password: user.password }}
  end
end
