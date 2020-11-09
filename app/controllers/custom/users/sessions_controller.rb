require_dependency Rails.root.join("app", "controllers", "users", "sessions_controller").to_s

class Users::SessionsController < Devise::SessionsController
  protect_from_forgery prepend: true, except: :participacion
  before_action :verify_ip, only: [:new]
  before_action :store_user_location!,  only: [:me]
  before_action :authenticate_user!, only: [:participacion]

  def participacion
    if(current_user)
      # Como el funcionamiento de la redirección es vía sistema externo, el estado de flash
      # de no autenticado queda marcado... lo eliminamos aqui para que se informe al usuario correctamente
      flash.discard(:alert)
      redirect_to after_sign_in_path_for(current_user)
    else
      redirect_to new_user_session_url
    end
  end

  def me
    if(current_user)
      redirect_to user_path (current_user.id)
    else
      redirect_to new_user_session_url
    end
  end

  private

    def after_sign_in_path_for(resource)
      returnTo = stored_location_for(resource);
      if(returnTo!=nil)
        returnTo
      else
        root_path
      end
    end

    def after_sign_out_path_for(resource)
      request.referer.present? && !request.referer.match("management") ? root_path : super
    end

    def storable_location?
      request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
    end

    def store_user_location!
      # :user is the scope we are authenticating
      store_location_for(:user, request.fullpath)
    end

    def verify_ip

      # Simplemente verificamos si la IP remota es una de las IPs de gestion
      # en caso negativo redirigimos la petición a la de renegociacion
      # del portal de participacion.. siempre y cuando el usuario no este conectado ya, claro...
      unless user_signed_in?
        # Usamos el request.ip, el remote_ip no parece dar resultados correctos en el entorno
        # del Ayto
        ip = request.ip
        managementIps = nil
        Rails.logger.debug "verifyIp: IP remota: #{ip}"
        Rails.logger.debug "verifyIp: La ip de cliente es: #{request.ip}"
        if(Rails.application.config.respond_to?(:participacion_management_ip))
          managementIps = Rails.application.config.participacion_management_ip
        end
        if(Rails.application.config.respond_to?(:participacion_renegotiation))
          redirect = Rails.application.config.participacion_renegotiation
        end
        Rails.logger.debug "verifyIp: IP de gestión #{managementIps}"
        Rails.logger.debug "verifyIp: IP de redirección #{redirect}"

        if(redirect!=nil)
          Rails.logger.debug "verifyIp: IP de redirección no nula, verificando IPs de gestión"
          managementIps.split(';').each{|m| Rails.logger.debug "verifyIp: --- evaluando [#{m.strip}] #{(m.strip == ip)}"}

          if(managementIps==nil || managementIps.split(';').none?{|m| m.strip == ip })
            Rails.logger.debug "verifyIp: Generando redirect a #{redirect} no hemos localizado ips validas"
            redirect_to redirect, :status => 302
          end
          Rails.logger.debug "verifyIp: Success!"
        end
      end
    end
end
