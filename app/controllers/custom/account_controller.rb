require_dependency Rails.root.join("app", "controllers", "account_controller").to_s

class AccountController < ApplicationController
  def update
    @account.skip_email_validation = true if @account.identities.exists?(provider: "codigo")

    if @account.update(account_params)
      redirect_to account_path, notice: t("flash.actions.save_changes.notice")
    else
      @account.errors.messages.delete(:organization)
      render :show
    end
  end
end
