require 'securerandom'
require 'base64'

class ExternalUserController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_authorization_check
  before_action :verify_participacion_token


  def authorize()
    if(params[:validated]==nil || !params[:fullname] || !params[:userId] || params[:association]==nil)
      render plain: 'invalid request', status: :bad_request
      return
    end
    uuid = SecureRandom.hex
    eu = ExternalUser.new(uuid:uuid, participacion_id: params[:userId], fullname: params[:fullname],email:params[:email],validated:params[:validated],organization:params[:association])
    eu.national_id = params[:nationalId] if params[:nationalId].present? && params[:validated].present?
    ## Almacenamos de forma persistente... seria mejor con un IPC; pero.
    eu.save!

    ## Debemos madnar el token de acceso... nos vamos a asegurar de que el usuario no nos manda nada que no sepamos que es invalido, para
    ## ello generamos un token JSON con dos partes
    hexdigest = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'),Rails.application.secrets.secret_key_base,uuid)
    token = Base64.urlsafe_encode64({uuid: uuid, mac: hexdigest}.to_json)

    # Debemos devolver la URL de validacion del usuario
    render json: "#{participacion_logon_path}?authToken=#{token}"
  end

  private
    def verify_participacion_token
      # Recuperamos la cabecera de autorizacion... si no viene o no tenemos definida una, salimos
      xauth = request.headers["x-auth-token"]
      if(xauth!=nil)
        xauth = xauth.strip
      end
      # Utilizamos directamente la IP de la request, el remote_ip no parece gustar demasiado...
      ip = request.ip
      # El secreto y el origen valido almacenado
      secret = nil
      origin = nil
      Rails.logger.debug "verify_participacion_token: Tenemos xauth-token: [#{xauth}] con ip remota: #{ip}"
      Rails.logger.debug "verify_participacion_token: La ip de cliente es: #{request.ip}"

      if(Rails.application.config.respond_to?(:participacion_xauth_secret))
        secret = Rails.application.config.participacion_xauth_secret.strip
      end
      if(Rails.application.config.respond_to?(:participacion_xauth_origin))
        origin = Rails.application.config.participacion_xauth_origin.strip
      end

      Rails.logger.debug "verify_participacion_token: Comprobando xauth-token: [#{(secret == xauth)}] con ip remota registrada: [#{origin}]"

      # Verificamos que tenemos todos los datos
      if (secret == nil || origin == nil || xauth == nil || xauth != secret)
        Rails.logger.debug "verify_participacion_token: Alguno de los datos es nulo o el secreto no es válido"
        render plain: 'unknown', status: :not_found
        return
      end

      origin.split(';').each{|m| Rails.logger.debug "verifyIp: --- evaluando [#{m.strip}] #{(m.strip == ip)}"}

      # Ahora comprobamos... si alguna ip coincide
      if(origin.split(';').none? {|m| m.strip == ip})
        Rails.logger.debug "verify_participacion_token: No hay coincidencia de IPs"
        render plain: 'unknown', status: :not_found
        return
      end
      Rails.logger.debug "verify_participacion_token: Success"

    end

end
