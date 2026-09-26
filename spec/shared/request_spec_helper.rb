module RequestSpecHelper
  def sign_in(user)
    ActionController::Base.with(allow_forgery_protection: false) do
      post user_session_path, params: { user: { login: user.email, password: user.password }}

      expect(response).to have_http_status(:redirect)
    end
  end
end
