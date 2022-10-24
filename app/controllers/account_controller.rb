class AccountController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account
  load_and_authorize_resource class: "User"

  def show
  end

  def update
    if @account.update(account_params)
      if session[:area_id] && session[:sub_area_id]
        redirect_to new_budget_investment_path(Budget.current, area_id: session[:area_id], sub_area_id: session[:sub_area_id])
      else
        redirect_to account_path, notice: t("flash.actions.save_changes.notice")
      end
    else
      @account.errors.messages.delete(:organization)
      render :show
    end
  end

  private

    def set_account
      @account = current_user
    end

    def account_params
      params.require(:account).permit(allowed_params)
    end

    def allowed_params
      if @account.organization?
        [:phone_number, :email_on_comment, :email_on_comment_reply, :newsletter,
         organization_attributes: [:name, :responsible_name]]
      else
        [:username, :public_activity, :public_interests, :email_on_comment,
         :email_on_comment_reply, :email_on_direct_message, :email_digest, :newsletter,
         :official_position_badge, :recommended_debates, :recommended_proposals]
      end
    end
end
