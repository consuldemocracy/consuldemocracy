class Management::SpendingProposalsController < Management::BaseController

  before_action :check_verified_user

  def new
    @spending_proposal = SpendingProposal.new
  end

  def create
    @spending_proposal = SpendingProposal.new(spending_proposal_params)
    @spending_proposal.author = managed_user

    if @spending_proposal.save_with_captcha
      redirect_to management_spending_proposal_path(@spending_proposal), notice: t('flash.actions.create.notice', resource_name: t("activerecord.models.spending_proposal", count: 1))
    else
      render :new
    end
  end

  def show
    @spending_proposal = SpendingProposal.find(params[:id])
  end

  private

    def spending_proposal_params
      params.require(:spending_proposal).permit(:title, :description, :external_url, :geozone_id, :terms_of_service, :captcha, :captcha_key)
    end

    def check_verified_user
      unless current_user.level_two_or_three_verified?
        redirect_to management_document_verifications_path, alert: t("management.spending_proposals.alert.unverified_user")
      end
    end

    def current_user
      managed_user
    end

end
