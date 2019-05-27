class Admin::SpendingProposalsController < Admin::BaseController
  include FeatureFlags
  before_action :load_filter_params
  feature_flag :spending_proposals

  has_filters %w{valuation_open without_admin managed valuating valuation_finished all}, only: :index

  load_and_authorize_resource

  def index
    @spending_proposals = SpendingProposal.scoped_filter(filter_params, @current_filter)
                                          .order(cached_votes_up: :desc, created_at: :desc)
                                          .page(params[:page])
  end

  def show
  end

  def edit
    load_admins
    load_valuators
    load_tags
  end

  def update
    if @spending_proposal.update(spending_proposal_params)
      redirect_to admin_spending_proposal_path(@spending_proposal, filter_params),
                  notice: t("flash.actions.update.spending_proposal")
    else
      load_admins
      load_valuators
      load_tags
      render :edit
    end
  end

  def summary
    @spending_proposals = SpendingProposal.group(:geozone).sum(:price).sort_by{|geozone, count| geozone.present? ? geozone.name : "z"}
    @spending_proposals_with_supports = SpendingProposal.with_supports.group(:geozone).sum(:price)
                                                        .sort_by{|geozone, count| geozone.present? ? geozone.name : "z"}
  end

  private

    def spending_proposal_params
      params.require(:spending_proposal).permit(:title, :description, :external_url, :geozone_id, :association_name,
                                                :administrator_id, :tag_list, valuator_ids: [])
    end

    def filter_params
      params.permit(:geozone_id, :administrator_id, :tag_name, :valuator_id)
    end

    def load_filter_params
      @filter_params ||= filter_params
    end

    def load_admins
      @admins = Administrator.includes(:user).all
    end

    def load_valuators
      @valuators = Valuator.includes(:user).all.order("description ASC").order("users.email ASC")
    end

    def load_tags
      @tags = ActsAsTaggableOn::Tag.spending_proposal_tags
    end

end
