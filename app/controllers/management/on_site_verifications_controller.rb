class Management::OnSiteVerificationsController < Management::BaseController

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
        redirect_to new_management_on_site_verification_email_path(verification_on_site_email: verification_on_site_params)
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

  private

  def verification_on_site_params
    params.require(:verification_on_site).permit(:document_type, :document_number)
  end


end



