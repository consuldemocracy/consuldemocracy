class AccountController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account
  load_and_authorize_resource class: "User"

  def show
    @area_id = params[:area_id]
  end

  def update
    if @account.update(account_params)
      if session[:area_id]
        redirect_to new_budget_investment_path(Budget.current, area_id: session[:area_id])
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
      attributes = if @account.organization?
                     [:phone_number, :email_on_comment, :email_on_comment_reply, :newsletter,
                      organization_attributes: [:name, :responsible_name]]
                   else
                     [:username, :public_activity, :public_interests, :email_on_comment,
                      :email_on_comment_reply, :email_on_direct_message, :email_digest, :newsletter,
                      :official_position_badge, :recommended_debates, :recommended_proposals,
                      :phone_number]
                   end
      params.require(:account).permit(*attributes)
    end

end
