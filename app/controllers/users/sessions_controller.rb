class Users::SessionsController < Devise::SessionsController

  private

    def after_sign_in_path_for(resource)
      reverificar_residencia(resource)
      if !verifying_via_email? && resource.show_welcome_screen?
        welcome_path
      else
        super
      end
    end

    def after_sign_out_path_for(resource)
      # root_path
      request.referer.present? ? request.referer : super
    end

    def verifying_via_email?
      return false if resource.blank?
      stored_path = session[stored_location_key_for(resource)] || ""
      stored_path[0..5] == "/email"
    end

    def reverificar_residencia(resource)
      # Verificamos si el usuario sigue empadronado en Castellón
      return true if !resource.residence_verified? || Rails.env.development?
      parametros = {
        document_number: resource.document_number,
        document_type: resource.document_type,
        date_of_birth: resource.date_of_birth,
        postal_code: '12000',
        terms_of_service: "1"
      }
      residence = Verification::Residence.new(parametros.merge(user: current_user))
      unless residence.save
        resource.residence_verified_at = nil
        resource.verified_at = nil
        resource.save
      end
    end

end
