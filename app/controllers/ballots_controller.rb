class BallotsController < ApplicationController
  before_action :authenticate_user!

  skip_authorization_check

  def show
    @ballot = current_user.ballot
  end

end
