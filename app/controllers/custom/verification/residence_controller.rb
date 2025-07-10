require_dependency Rails.root.join("app", "controllers", "verification", "residence_controller").to_s

class Verification::ResidenceController < ApplicationController
  def new
    @residence = Verification::Residence.new
    @residence.document_type = current_user.document_type
    @residence.date_of_birth = current_user.date_of_birth
    @residence.postal_code = current_user.postal_code
  end

  def create
    @residence = Verification::Residence.new(residence_params.merge(user: current_user))
    if @residence.save
      current_user.update(verified_at: Time.now)
      redirect_to account_path, notice: t("verification.residence.create.flash.success")
    else
      render :new
    end
  end
end
