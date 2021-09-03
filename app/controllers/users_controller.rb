class UsersController < ApplicationController
  load_and_authorize_resource
  helper_method :valid_interests_access?
  helper_method :authorized_current_user?

  def show
  end

  private

    def valid_interests_access?
      @user.public_interests || authorized_current_user?
    end

    def authorized_current_user?
      @authorized_current_user ||= current_user && (current_user == @user || current_user.moderator? || current_user.administrator?)
    end
end
