class PhoneContactController < ApplicationController
  skip_authorization_check
  layout "contact"

  def index
  end

  def create
    @params=params
    ContactMailer.phone_contact(params).deliver
    flash[:notice]= "Formulario enviado"
    redirect_to root_path
  end
end
