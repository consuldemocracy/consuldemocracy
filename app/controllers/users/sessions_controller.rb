class Users::SessionsController < Devise::SessionsController
  before_action :verify_ip, only: [:new]
  private

    def after_sign_in_path_for(resource)
      if !verifying_via_email? && resource.show_welcome_screen?
        welcome_path
      else
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

    def verify_ip
      # Simplemente verificamos si la IP remota es una de las IPs de gestion
      # en caso negativo redirigimos la petición a la de renegociacion
      # del portal de participacion.. siempre y cuando el usuario no este conectado ya, claro...
      unless user_signed_in?
        @ip = request.remote_ip
        @managementIps = nil
        if(Rails.application.config.respond_to?(:participacion_management_ip))
            @managementIps = Rails.application.config.participacion_management_ip
        end
        if(Rails.application.config.respond_to?(:participacion_renegotiation))
          @redirect = Rails.application.config.participacion_renegotiation
        end


        if(@redirect!=nil && @managementIps!=nil)
          if(@managementIps.split(';').none?{|m| m.strip == @ip })
            redirect_to @redirect, :status => 302
          end
        end
      end
    end
end
