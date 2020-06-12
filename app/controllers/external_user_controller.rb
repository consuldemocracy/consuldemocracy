require 'securerandom'
require 'base64'

class ExternalUserController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_authorization_check
  before_action :verify_participacion_token

  def authorize()
    if(params[:validated]==nil || !params[:fullname] || !params[:email] || params[:association]==nil)
      render plain: 'invalid request', status: :bad_request
      return
    end
    uuid = SecureRandom.hex
    eu = ExternalUser.new(uuid:uuid, fullname: params[:fullname],email:params[:email],validated:params[:validated],organization:params[:association])
    ## Almacenamos de forma persistente... seria mejor con un IPC; pero.
    eu.save!

    ## Debemos madnar el token de acceso... nos vamos a asegurar de que el usuario no nos manda nada que no sepamos que es invalido, para
    ## ello generamos un token JSON con dos partes
    hexdigest = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'),Rails.application.secrets.secret_key_base,uuid)
    token = Base64.urlsafe_encode64({uuid: uuid, mac: hexdigest}.to_json)

    # Debemos devolver la URL de validacion del usuario
    render json: "#{participacion_logon_url}?authToken=#{token}"
  end

  private
    def verify_participacion_token
      # Recuperamos la cabecera de autorizacion... si no viene o no tenemos definida una, salimos
      xauth = request.headers["x-auth-token"]
      if(xauth!=nil)
        xauth = xauth.strip
      end
      ip = request.remote_ip
      # El secreto y el origen valido almacenado
      secret = nil
      origin = nil
      if(Rails.application.config.respond_to?(:participacion_xauth_secret))
        secret = Rails.application.config.participacion_xauth_secret.strip
      end
      if(Rails.application.config.respond_to?(:participacion_xauth_origin))
        origin = Rails.application.config.participacion_xauth_origin.strip
      end

      # Verificamos que tenemos todos los datos
      if (secret == nil || origin == nil || xauth == nil || xauth != secret)
        render plain: 'unknown', status: :not_found
        return
      end

      # Ahora comprobamos... si alguna ip coincide
      if(origin.split(';').none? {|m| m.strip == ip})
        render plain: 'unknown', status: :not_found
        return
      end

    end

end
