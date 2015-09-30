class Management::OnSiteVerificationsController < ActionController::Base

  def index
    @verification_on_site = Verification::OnSite.new()
  end

  def check
    @verification_on_site = Verification::OnSite.new(verification_on_site_params)

    if @verification_on_site.valid?
      if @verification_on_site.verified?
        render :verified
      elsif @verification_on_site.user?
        render :new
      elsif @verification_on_site.in_census?
        render :existing_user
      else
        render :invalid_document
      end
    else
      render :index
    end
  end

  def create
    @verification_on_site = Verification::OnSite.new(verification_on_site_params)
    @verification_on_site.verify
    render :verified
  end

  def send_email
    @verification_on_site = Verification::OnSite.new(verification_on_site_with_email_params)
    @verification_on_site.should_validate_email = true

    if @verification_on_site.valid?
      @verification_on_site.send_verification_email
      render :email_sent
    else
      render :existing_user
    end
  end

  private

  def verification_on_site_params
    params.require(:verification_on_site).permit(:document_type, :document_number)
  end

  def verification_on_site_with_email_params
    params.require(:verification_on_site).permit(:document_type, :document_number, :email)
  end
end



