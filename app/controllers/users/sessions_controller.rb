class Users::SessionsController < Devise::SessionsController
  private

    def after_sign_in_path_for(resource)
      Rails.logger.info "="*50
      Rails.logger.info "ENTRANDO EN after_sign_in_path_for"
      Rails.logger.info "Resource: #{resource.inspect}"
      Rails.logger.info "Sexo: #{resource.gender.inspect}"
      Rails.logger.info "Sexo nil?: #{resource.gender.nil?}"
      Rails.logger.info "Sexo blank?: #{resource.gender.blank?}"
      Rails.logger.info "="*50
	  
      
      if !verifying_via_email? && resource.show_welcome_screen?
        Rails.logger.info "→ Redirigiendo a welcome_path"
        welcome_path
      elsif resource.gender.nil? && !resource.organization?
          Rails.logger.info "ENTRANDO EN account_path"
          Rails.logger.info "Es organización?: #{resource.organization?}"
          account_path
      else
        Rails.logger.info "→ Redirigiendo con super (ruta por defecto)"
        super
      end
    end

    def after_sign_out_path_for(resource)
      request.referer.present? && !request.referer.match("management") ? request.referer : super
    end

    def verifying_via_email?
      return false if resource.blank?

      stored_path = session[stored_location_key_for(resource)] || ""
      stored_path[0..5] == "/email"
    end
end

