class Users::ConfirmationsController < Devise::ConfirmationsController
  # POST /resource/confirmation
  def create
    self.resource = resource_class.send_confirmation_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      Mailer.already_confirmed(resource).deliver_later unless resource.confirmation_required?
      respond_with({}, location: after_resending_confirmation_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end

  # new action, PATCH does not exist in the default Devise::ConfirmationsController
  # PATCH /resource/confirmation
  def update
    self.resource = resource_class.find_by(confirmation_token: params[:confirmation_token])

    if resource.encrypted_password.blank?
      resource.assign_attributes(resource_params)

      if resource.valid? # password is set correctly
        resource.save!
        set_official_position if resource.has_official_email?
        resource.confirm
        set_flash_message(:notice, :confirmed) if is_flashing_format?
        sign_in_and_redirect(resource_name, resource)
      else
        render :show
      end
    else
      resource.errors.add(:email, :password_already_set)
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    # In the default implementation, this already confirms the resource:
    # self.resource = self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    self.resource = resource_class.find_by!(confirmation_token: params[:confirmation_token])

    yield resource if block_given?

    # New condition added to if: when no password was given, display the "show" view
    # (which uses "update" above)
    if resource.encrypted_password.blank?
      respond_with_navigational(resource) { render :show }
    elsif resource.errors.empty?
      set_official_position if resource.has_official_email?

      if resource.confirm
        set_flash_message(:notice, :confirmed) if is_flashing_format?

        respond_with_navigational(resource) do
          redirect_to after_confirmation_path_for(resource_name, resource)
        end
      else
        respond_with_navigational(resource.errors, status: :unprocessable_entity) do
          render :new, status: :unprocessable_entity
        end
      end
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end

  protected

    def resource_params
      params.require(resource_name).permit(allowed_params)
    end

    def allowed_params
      [:password, :password_confirmation, :email]
    end

  private

    def set_official_position
      resource.add_official_position!(Setting["official_level_1_name"], 1)
    end
end
