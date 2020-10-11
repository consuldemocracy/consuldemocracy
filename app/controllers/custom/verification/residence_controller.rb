require_dependency Rails.root.join("app", "controllers", "verification", "residence_controller").to_s

class Verification::ResidenceController

  def create
    @residence = Verification::Residence.new(residence_params.merge(user: current_user))
    if @residence.save
      current_user.update!(verified_at: Time.current)
      redirect_to account_path, notice: t("verification.letter.update.flash.success")
    else
      render :new
    end
  end
end
