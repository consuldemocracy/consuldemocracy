require_dependency Rails.root.join("app", "controllers", "management", "users_controller").to_s

class Management::UsersController < Management::BaseController
  def create
    @user = User.new(user_params)

    if @user.email.blank?
      user_without_email
    else
      user_with_email
    end

    @user.terms_of_service = "1"
    @user.residence_verified_at = Time.current
    @user.verified_at = Time.current

    # Modificación para registrar el gestor que creó el usuario
    @user.created_by = current_manager["login"].to_s.scan(/\d/).join("").to_i

    if @user.save
      render :show
    else
      render :new
    end
  end
end
