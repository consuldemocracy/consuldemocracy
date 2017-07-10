class Management::SpendingProposalsController < Management::BaseController

  before_action :only_verified_users, except: :print
  before_action :set_spending_proposal, only: [:vote, :show]

  def index
    @spending_proposals = apply_filters_and_search(SpendingProposal).order(cached_votes_up: :desc).page(params[:page]).for_render
    set_spending_proposal_votes(@spending_proposals)
  end

  def new
    @spending_proposal = SpendingProposal.new
  end

  def create
    @spending_proposal = SpendingProposal.new(spending_proposal_params)
    @spending_proposal.author = managed_user

    if @spending_proposal.save
      notice = t('flash.actions.create.notice', resource_name: t("activerecord.models.spending_proposal", count: 1))
      redirect_to management_spending_proposal_path(@spending_proposal), notice: notice
    else
      render :new
    end
  end

  def show
    set_spending_proposal_votes(@spending_proposal)
  end

  def vote
    @spending_proposal.register_vote(managed_user, 'yes')
    set_spending_proposal_votes(@spending_proposal)
  end

  def print
    params[:geozone] ||= 'all'
    @spending_proposals = apply_filters_and_search(SpendingProposal).order(cached_votes_up: :desc).for_render.limit(15)
    set_spending_proposal_votes(@spending_proposals)
  end

  private

    def set_spending_proposal
      @spending_proposal = SpendingProposal.find(params[:id])
    end

    def spending_proposal_params
      params.require(:spending_proposal).permit(:title, :description, :external_url, :geozone_id, :terms_of_service)
    end

    def only_verified_users
      check_verified_user t("management.spending_proposals.alert.unverified_user")
    end

    # This should not be necessary. Maybe we could create a specific show view for managers.
    def set_spending_proposal_votes(spending_proposals)
      @spending_proposal_votes = managed_user ? managed_user.spending_proposal_votes(spending_proposals) : {}
    end

    def set_geozone_name
      if params[:geozone] == 'all'
        @geozone_name = t('geozones.none')
      else
        @geozone_name = Geozone.find(params[:geozone]).name
      end
    end

    def apply_filters_and_search(target)
      target = params[:unfeasible].present? ? target.unfeasible : target.not_unfeasible
      if params[:geozone].present?
        target = target.by_geozone(params[:geozone])
        set_geozone_name
      end
      target = target.search(params[:search]) if params[:search].present?
      target
    end

end
