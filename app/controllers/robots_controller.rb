class RobotsController < ApplicationController
  skip_authorization_check

  def index
    respond_to :text
  end
end
