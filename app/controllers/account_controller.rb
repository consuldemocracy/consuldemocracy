class AccountController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account
  load_and_authorize_resource class: "User"

  def show
  end

  def update
    if @account.update(account_params)
      redirect_to account_path, notice: t("flash.actions.save_changes.notice")
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
      if @account.organization?
        params.require(:account).permit(:phone_number, :email_on_debate_comment, :email_on_comment_reply, organization_attributes: [:name])
      else
        params.require(:account).permit(:username, :email_on_debate_comment, :email_on_comment_reply)
      end
    end

end
