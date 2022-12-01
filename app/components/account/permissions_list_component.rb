class Account::PermissionsListComponent < ApplicationComponent
  attr_reader :user

  def initialize(user)
    @user = user
  end

  private

    def permissions
      {
        t("verification.user_permission_debates") => true,
        t("verification.user_permission_proposal") => true,
        t("verification.user_permission_support_proposal") => user.level_two_or_three_verified?,
        t("verification.user_permission_votes") => user.level_three_verified?
      }
    end

    def allowed_class(allowed)
      if allowed
        "permission-allowed"
      else
        "permission-denied"
      end
    end
end
