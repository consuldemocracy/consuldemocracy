class SpendingProposalsController < ApplicationController
  include FeatureFlags

  load_and_authorize_resource

  before_action :authenticate_user!, except: [:index]
  before_action :verify_access, only: [:show]
  before_filter -> { flash.now[:notice] = flash[:notice].html_safe if flash[:html_safe] && flash[:notice] }

  feature_flag :spending_proposals

  def index
  end

  def new
    @spending_proposal = SpendingProposal.new
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

  private

    def spending_proposal_params
      params.require(:spending_proposal).permit(:title, :description, :external_url, :geozone_id, :association_name, :terms_of_service, :captcha, :captcha_key)
    end

    def verify_access
      raise CanCan::AccessDenied unless current_user.try(:valuator?) || current_user.try(:administrator?) || @spending_proposal.author == current_user
    end

end
