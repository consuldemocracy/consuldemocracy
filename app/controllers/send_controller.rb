class SendController < ApplicationController
  skip_authorization_check
  layout "contact"
  
  def index
  end

  def create
    @params=params
    ContactMailer.contact_send(params).deliver
    flash[:notice]= "Formulario enviado"
    redirect_to root_path
  end
end