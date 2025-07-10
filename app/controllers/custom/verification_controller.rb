require_dependency Rails.root.join("app", "controllers", "verification_controller").to_s

class VerificationController < ApplicationController
  private

    def next_step_path(user = current_user)
      if user.organization?
        { path: account_path }
      elsif user.level_three_verified?
        { path: account_path, notice: t("verification.redirect_notices.already_verified") }
      else
        { path: new_residence_path }
      end
    end
end
