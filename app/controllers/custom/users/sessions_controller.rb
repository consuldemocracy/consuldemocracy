require_dependency Rails.root.join("app", "controllers", "users", "sessions_controller").to_s

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
		    Rails.logger.info "ENTRANDO EN verifying_via_email, welcome_path"
        welcome_path
      else
        Rails.logger.info "NO verifying_via_email "
        if resource.gender.nil? && !resource.organization?
          Rails.logger.info "ENTRANDO EN account_path"
          Rails.logger.info "Es organización?: #{resource.organization?}"
          account_path
        else
          Rails.logger.info "ENTRANDO EN root_path"
          root_path
        end
      end
    end


    def after_sign_out_path_for(resource)
      request.referer.present? && !request.referer.match("management") ? root_path : super
    end
end
