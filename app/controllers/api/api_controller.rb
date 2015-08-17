class Api::ApiController < ApplicationController
  skip_authorization_check
  before_action :authenticate_user!
  protect_from_forgery with: :null_session
end
