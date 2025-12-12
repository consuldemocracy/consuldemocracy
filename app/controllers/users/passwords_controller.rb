class Users::PasswordsController < Devise::PasswordsController
  def update
    Rails.logger.info "=" * 80
    Rails.logger.info "PASSWORDS#update PERSONALIZADO RESET"
    
    # Sobrescribir reset_password_by_token para skipear validación de gender
    original_token = resource_params[:reset_password_token]
    reset_password_token = Devise.token_generator.digest(User, :reset_password_token, original_token)
    self.resource = User.find_or_initialize_with_error_by(:reset_password_token, reset_password_token)
    
    Rails.logger.info "Usuario encontrado: #{resource.persisted?}"
    
    if resource.persisted?
      if resource.reset_password_period_valid?
        # IMPORTANTE: Skipear validación ANTES del reset_password
        resource.skip_gender_validation = true
        Rails.logger.info "skip_gender_validation asignado: #{resource.skip_gender_validation}"
        
        # Ahora sí hacer el reset
        if resource_params[:password].present?
          resource.password = resource_params[:password]
          resource.password_confirmation = resource_params[:password_confirmation]
          resource.save
        else
          resource.errors.add(:password, :blank)
        end
      else
        resource.errors.add(:reset_password_token, :expired)
      end
    end
    
    resource.reset_password_token = original_token if resource.reset_password_token.present?
    
    Rails.logger.info "Errores: #{resource.errors.full_messages.inspect}"
    Rails.logger.info "=" * 80
    
    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      if Devise.sign_in_after_reset_password
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message!(:notice, flash_message)
        resource.after_database_authentication
        sign_in(resource_name, resource)
      else
        set_flash_message!(:notice, :updated_not_active)
      end
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      Rails.logger.error "FALLO AL GUARDAR PASSWORD"
      set_minimum_password_length
      respond_with resource
    end
  end
end