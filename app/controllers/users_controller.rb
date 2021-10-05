class UsersController < ApplicationController
  load_and_authorize_resource
  helper_method :valid_interests_access?

  def show
    raise CanCan::AccessDenied if params[:filter] == "follows" && !valid_interests_access?(@user)
  end

  private

    def valid_interests_access?(user)
      user.public_interests || user == current_user
    end
end
