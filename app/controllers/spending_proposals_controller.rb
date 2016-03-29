class SpendingProposalsController < ApplicationController
  include FeatureFlags

  before_action :authenticate_user!, except: [:index]

  load_and_authorize_resource

  before_filter -> { flash.now[:notice] = flash[:notice].html_safe if flash[:html_safe] && flash[:notice] }

  feature_flag :spending_proposals

  respond_to :html, :js

  def index
    @spending_proposals = @search_terms.present? ? SpendingProposal.search(@search_terms) : SpendingProposal.all
    @spending_proposals = @spending_proposals.page(params[:page]).for_render
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

    if @spending_proposal.save_with_captcha
      notice = t('flash.actions.create.spending_proposal', activity: "<a href='#{user_path(current_user, filter: :spending_proposals)}'>#{t('layouts.header.my_activity_link')}</a>")
      redirect_to @spending_proposal, notice: notice, flash: { html_safe: true }
    else
      render :new
    end
  end

  def destroy
    spending_proposal = current_user.spending_proposals.find(params[:id])
    spending_proposal.destroy
    redirect_to user_path(current_user, filter: 'spending_proposals'), notice: t('flash.actions.destroy.spending_proposal')
  end

  def vote
    @spending_proposal.register_vote(current_user, 'yes')
    set_spending_proposal_votes(@spending_proposal)
  end


  private

    def spending_proposal_params
      params.require(:spending_proposal).permit(:title, :description, :external_url, :geozone_id, :association_name, :terms_of_service, :captcha, :captcha_key)
    end

end
