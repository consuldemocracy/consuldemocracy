class Admin::Api::BaseController < Admin::BaseController
  protect_from_forgery with: :null_session
end
