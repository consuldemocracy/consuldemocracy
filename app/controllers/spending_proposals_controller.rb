class SpendingProposalsController < ApplicationController
  include FeatureFlags
  include CommentableActions
  include FlagActions

  before_action :authenticate_user!, except: [:index, :welcome, :show, :select_district]
  before_action -> { flash.now[:notice] = flash[:notice].html_safe if flash[:html_safe] && flash[:notice] }
  before_action :set_random_seed, only: :index
  before_action :load_ballot,  only: [:index, :show]
  before_action :load_geozone, only: [:index, :show]
  before_action :has_index_orders, only: :index

  has_orders %w{most_voted newest oldest}, only: :show

  load_and_authorize_resource

  feature_flag :spending_proposals

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  respond_to :html, :js

  def index
    @spending_proposals = apply_filters_and_search(SpendingProposal).send("sort_by_#{@current_order}", params[:random_seed]).page(params[:page]).per(10).for_render
    set_spending_proposal_votes(@spending_proposals)
  end

  def select_district
    @geozones = Geozone.all.order(name: :asc)
  end

  def new
    @spending_proposal = SpendingProposal.new
  end

  def show
    @commentable = @spending_proposal
    @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
    set_comment_flags(@comment_tree.comments)
    set_spending_proposal_votes(@spending_proposal)
  end

  def create
    @spending_proposal = SpendingProposal.new(spending_proposal_params)
    @spending_proposal.author = current_user

    if @spending_proposal.save
      notice = t('flash.actions.create.spending_proposal', activity: "<a href='#{user_path(current_user, filter: :spending_proposals)}'>#{t('layouts.header.my_activity_link')}</a>")
      redirect_to @spending_proposal, notice: notice, flash: { html_safe: true }
    else
      render :new
    end
  end

  def destroy
    spending_proposal = SpendingProposal.find(params[:id])
    spending_proposal.destroy
    redirect_to user_path(current_user, filter: 'spending_proposals'), notice: t('flash.actions.destroy.spending_proposal')
  end

  def vote
    @spending_proposal.register_vote(current_user, 'yes')
    set_spending_proposal_votes(@spending_proposal)
    if current_user.pending_delegation_alert?
      current_user.update(accepted_delegation_alert: true, representative: nil)
      @accepted_delegation_alert = true
    end
  end

  def stats
  end

  private

    def spending_proposal_params
      params.require(:spending_proposal).permit(:title, :description, :external_url, :geozone_id, :association_name, :terms_of_service)
    end

    def set_filter_geozone
      if params[:geozone] == 'all'
        @filter_geozone_name = t('geozones.none')
      else
        @filter_geozone = Geozone.find(params[:geozone])
        @filter_geozone_name = @filter_geozone.name
      end
    end

    def apply_filters_and_search(target)
      default_target = Setting["feature.spending_proposal_features.phase3"].present? ? target.feasible.valuation_finished : target.not_unfeasible
      target = params[:unfeasible].present? ? target.unfeasible : default_target
      params[:geozone] = 'all' if params[:geozone].blank?
      target = target.by_geozone(params[:geozone])
      set_filter_geozone

      if params[:forum].present?
        target = target.by_forum
      end
      target = target.search(params[:search]) if params[:search].present?
      target
    end

    def set_random_seed
      if params[:order] == 'random' || params[:order].blank?
        params[:random_seed] ||= rand(99)/100.0
        SpendingProposal.connection.execute "select setseed(#{params[:random_seed]})"
      else
        params[:random_seed] = nil
      end
    end

    def load_ballot
      @ballot = Ballot.where(user: current_user).first_or_create
    end

    def load_geozone
      @geozone = Geozone.find(params[:geozone]) if geozone?
    end

    def geozone?
      params[:geozone].present? && params[:geozone] != 'all'
    end

    def has_index_orders
      if Setting["feature.spending_proposal_features.phase3"].present?
        @valid_orders = %w{random price}
      else
        @valid_orders = %w{random confidence_score}
      end
      @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first
  end

end