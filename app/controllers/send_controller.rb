class SendController < ApplicationController
  skip_authorization_check
  layout "contact"

  def index
  end

  def create
    if params[:terms_of_service]!="1"
      render :index, notice: 'Debe aceptar las condiciones'
    else
      @params=params
      ContactMailer.contact_send(params).deliver
      flash[:notice]= "Formulario enviado"
      redirect_to root_path
    end
  end
end