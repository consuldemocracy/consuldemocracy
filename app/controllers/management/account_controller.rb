class Management::AccountController < Management::BaseController

  before_action :only_verified_users

  def show
  end

  private

    def only_verified_users
      check_verified_user t("management.account.alert.unverified_user")
    end

end
