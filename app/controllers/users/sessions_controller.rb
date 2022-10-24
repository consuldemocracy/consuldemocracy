class Users::SessionsController < Devise::SessionsController
  def destroy
    @stored_location = stored_location_for(:user)
    super
  end

  private

    def after_sign_in_path_for(resource)
      reverificar_residencia(resource)
      if !verifying_via_email? && resource.show_welcome_screen?
        welcome_path
      else
        scope = Devise::Mapping.find_scope!(resource)
        return_path = stored_location_for(scope)
        puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///"
        puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///"
        puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///"
        puts return_path.inspect
        puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///"
        puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///"
        puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@///"
        return_path || root_path
        # super
      end
    end

    def after_sign_out_path_for(resource)
      #request.referer.present? && !request.referer.match("management") ? request.referer : super
      #root_path
      @stored_location.present? && !@stored_location.match("management") ? @stored_location : super
    end

    def verifying_via_email?
      return false if resource.blank?

      stored_path = session[stored_location_key_for(resource)] || ""
      stored_path[0..5] == "/email"
    end

    def reverificar_residencia(resource)
      # Verificamos si el usuario sigue empadronado en Castellón
      return true #if !resource.residence_verified? || Rails.env.development?

      respuesta_padron = PadronCastellonApi.new.call(resource.document_type, resource.document_number)
      if !respuesta_padron.valid?
        resource.residence_verified_at = nil
        resource.verified_at = nil
        resource.save
      end
      true
    end

end
