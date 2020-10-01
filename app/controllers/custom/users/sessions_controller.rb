require_dependency Rails.root.join("app", "controllers", "users", "sessions_controller").to_s

class Users::SessionsController < Devise::SessionsController
  protect_from_forgery prepend: true, except: :participacion
  before_action :verify_ip, only: [:new]
  before_action :store_user_location!, if: :storable_location?, only: [:me]
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
      stored_location_for(resource) || root_path
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
