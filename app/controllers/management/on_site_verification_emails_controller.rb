class Management::OnSiteVerificationEmailsController < Management::BaseController

  def new
    @verification_on_site_email = Verification::OnSiteEmail.new(verification_on_site_email_params)
  end

  def create
    @verification_on_site_email = Verification::OnSiteEmail.new(verification_on_site_email_params)

    if @verification_on_site_email.valid?
      @verification_on_site_email.send_email
      render :sent
    else
      render :new
    end
  end

  private

  def verification_on_site_email_params
    params.require(:verification_on_site_email).permit(:document_type, :document_number, :email)
  end

end

