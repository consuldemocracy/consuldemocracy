class Management::OrganizationVerificationsController < Management::BaseController

  def new
    @organization_verification = Verification::Management::Organization.new
  end

  def create
    @organization_verification = Verification::Management::Organization.new(organization_verification_params)
    u = @organization_verification.user
    if u
      session[:organization_email] = u.email
      redirect_to create_investments_management_budgets_path
    else
      render :new
    end
  end

  private

    def organization_verification_params
      params.require(:organization_verification).permit(:email)
    end

end
