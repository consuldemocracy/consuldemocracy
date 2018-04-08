class SpendingProposalsController < ApplicationController
  include FeatureFlags

  before_action :authenticate_user!, except: [:index, :show]
  before_action -> { flash.now[:notice] = flash[:notice].html_safe if flash[:html_safe] && flash[:notice] }

  load_and_authorize_resource

  feature_flag :spending_proposals

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  respond_to :html, :js

  def index
    @spending_proposals = apply_filters_and_search(SpendingProposal).page(params[:page]).for_render
    set_spending_proposal_votes(@spending_proposals)
  end

  def new
    @spending_proposal = SpendingProposal.new
  end

  def show
    set_spending_proposal_votes(@spending_proposal)
  end

  def create
    @spending_proposal = SpendingProposal.new(spending_proposal_params)
    @spending_proposal.author = current_user

    if @spending_proposal.save
      activity = "<a href='#{user_path(current_user, filter: :spending_proposals)}'>#{t('layouts.header.my_activity_link')}</a>"
      notice = t('flash.actions.create.spending_proposal', activity: activity)
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
  end

  private

    def spending_proposal_params
      params.require(:spending_proposal).permit(:title, :description, :external_url, :geozone_id, :association_name, :terms_of_service)
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
