class Users::ConfirmationsController < Devise::ConfirmationsController

  # new action, PATCH does not exist in the default Devise::ConfirmationsController
  # PATCH /resource/confirmation
  def update
    self.resource = resource_class.find_by_confirmation_token(params[:confirmation_token])

    if resource.encrypted_password.blank?
      resource.assign_attributes(resource_params)

      if resource.valid? # password is set correctly
        resource.save
        resource.confirm
        set_flash_message(:notice, :confirmed) if is_flashing_format?
        sign_in_and_redirect(resource_name, resource)
      else
        render :show
      end
    else
      resource.errors.add(:email, :password_already_set)
      respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    # In the default implementation, this already confirms the resource:
    # self.resource = self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    self.resource = resource_class.find_by_confirmation_token(params[:confirmation_token])

    yield resource if block_given?

    # New condition added to if: when no password was given, display the "show" view (which uses "update" above)
    if resource.encrypted_password.blank?
      respond_with_navigational(resource){ render :show }
    elsif resource.errors.empty?
      resource.confirm # Last change: confirm happens here for people with passwords instead of af the top of the show action
      set_flash_message(:notice, :confirmed) if is_flashing_format?
      respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
    end
  end

  protected

    def resource_params
      params.require(resource_name).permit(:password, :password_confirmation, :email)
    end

end
