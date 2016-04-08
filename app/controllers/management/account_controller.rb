class Management::AccountController < Management::BaseController

  before_action :check_verified_user

  def show
  end

  private
    def check_verified_user
      unless current_user.level_two_or_three_verified?
        redirect_to management_document_verifications_path, alert: t("management.account.alert.unverified_user")
      end
    end

    def current_user
      managed_user
    end

end
