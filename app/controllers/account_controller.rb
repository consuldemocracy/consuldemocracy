class AccountController < ApplicationController

  before_action :authenticate_user!
  before_action :set_account

  def show
  end

  def update
    flash[:notice] = t("flash.actions.save_changes.notice") if @account.update(account_params)
    redirect_to account_path
  end

  private
    def set_account
      @account = current_user
    end

    def account_params
      params.require(:account).permit(:first_name, :last_name)
    end

end
