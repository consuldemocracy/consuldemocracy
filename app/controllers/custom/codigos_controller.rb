class CodigosController < ApplicationController
  skip_before_filter :verify_authenticity_token
  skip_authorization_check only: [:api, :create, :new]

  # POST /codigos/api
  def api
    if Codigo.exists?(clave: params[:clave])
      @usuario = Codigo.find_by(clave: params[:clave])
      @acceso = Digest::SHA1.hexdigest(@usuario.valor)

      if @acceso.to_s == params[:valor]
        render json: @usuario, except: [:valor]
      else
        error_datos
      end

    else
      error_datos
    end
  end

  def error_datos
    render json: { "error" => "no encontrado" }.to_json
  end

  def new; end

  def create
    valor_sha1 = Digest::SHA1.hexdigest(request["valor"])
    redirect_to controller: "users/omniauth_callbacks",
                action: "codigo",
                clave: request["clave"],
                valor: valor_sha1
  end
end
