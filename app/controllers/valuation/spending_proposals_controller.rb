class Valuation::SpendingProposalsController < Valuation::BaseController
  include FeatureFlags
  feature_flag :spending_proposals

  before_action :restrict_access_to_assigned_items, only: [:show, :edit, :valuate]

  has_filters %w{valuating valuation_finished}, only: :index

  load_and_authorize_resource

  def index
    @geozone_filters = geozone_filters
    @spending_proposals = if current_user.valuator?
                            SpendingProposal.scoped_filter(params_for_current_valuator, @current_filter)
                                            .order(cached_votes_up: :desc)
                                            .page(params[:page])
                          else
                            SpendingProposal.none.page(params[:page])
                          end
  end

  def valuate
    if valid_price_params? && @spending_proposal.update(valuation_params)

      if @spending_proposal.unfeasible_email_pending?
        @spending_proposal.send_unfeasible_email
      end

      redirect_to valuation_spending_proposal_path(@spending_proposal), notice: t('valuation.spending_proposals.notice.valuate')
    else
      render action: :edit
    end
  end

  private

    def geozone_filters
      spending_proposals = SpendingProposal.by_valuator(current_user.valuator.try(:id)).valuation_open.all.to_a

      [ { name: t('valuation.spending_proposals.index.geozone_filter_all'),
          id: nil,
          pending_count: spending_proposals.size
        },
        { name: t('geozones.none'),
          id: 'all',
          pending_count: spending_proposals.count{|x| x.geozone_id.nil?}
        }
      ] + Geozone.all.order(name: :asc).collect do |g|
        { name: g.name,
          id: g.id,
          pending_count: spending_proposals.count{|x| x.geozone_id == g.id}
        }
      end.select{ |x| x[:pending_count] > 0 }
    end

    def valuation_params
      params[:spending_proposal][:feasible] = nil if params[:spending_proposal][:feasible] == 'nil'

      params.require(:spending_proposal).permit(:price, :price_first_year, :price_explanation, :feasible, :feasible_explanation,
                                                :time_scope, :valuation_finished, :internal_comments)
    end

    def params_for_current_valuator
      params.merge(valuator_id: current_user.valuator.id)
    end

    def restrict_access_to_assigned_items
      return if current_user.administrator? ||
                ValuationAssignment.exists?(spending_proposal_id: params[:id], valuator_id: current_user.valuator.id)
      raise ActionController::RoutingError.new('Not Found')
    end

    def valid_price_params?
      if /\D/.match params[:spending_proposal][:price]
        @spending_proposal.errors.add(:price, I18n.t('spending_proposals.wrong_price_format'))
      end

      if /\D/.match params[:spending_proposal][:price_first_year]
        @spending_proposal.errors.add(:price_first_year, I18n.t('spending_proposals.wrong_price_format'))
      end

      @spending_proposal.errors.empty?
    end

end
