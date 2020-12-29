class SubscriptionsController < ApplicationController
  before_action :set_user
  skip_authorization_check

  def edit
  end

  private

    def set_user
      @user = if params[:token].present?
                User.find_by!(subscriptions_token: params[:token])
              else
                current_user || raise(CanCan::AccessDenied)
              end
    end
end
