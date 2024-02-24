class UsersController < ApplicationController
  load_and_authorize_resource
  before_action :check_slug
  helper_method :valid_interests_access?

  def show
    raise CanCan::AccessDenied if params[:filter] == "follows" && !valid_interests_access?(@user)
  end

  private

    def check_slug
      slug = params[:id].split("-", 2)[1]

      raise ActiveRecord::RecordNotFound unless @user.slug == slug.to_s
    end

    def valid_interests_access?(user)
      user.public_interests || user == current_user
    end
end
