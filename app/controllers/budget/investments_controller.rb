class Budget
  class InvestmentsController < ApplicationController
    include FeatureFlags

    before_action :load_investments, only: [:index]
    before_action :load_geozone, only: [:index, :unfeasible]

    skip_authorization_check

    before_action :authenticate_user!, except: [:index, :show]
    before_action -> { flash.now[:notice] = flash[:notice].html_safe if flash[:html_safe] && flash[:notice] }

    load_and_authorize_resource

    feature_flag :spending_proposals

    invisible_captcha only: [:create, :update], honeypot: :subtitle

    respond_to :html, :js

    def index
      load_investments
      set_spending_proposal_votes(@investments)
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
    end

    private

      def spending_proposal_params
        params.require(:spending_proposal).permit(:title, :description, :external_url, :geozone_id, :association_name, :terms_of_service)
      end

      def load_investments
        @investments = filter_and_search(Budget::Investment)
      end

      def filter_and_search(target)
        target = target.unfeasible if params[:unfeasible].present?
        target = target.by_geozone(params[:geozone]) if params[:geozone].present?
        target = target.search(params[:search])      if params[:search].present?
        target.page(params[:page]).for_render
      end

      def load_geozone
        return if params[:geozone].blank?

        if params[:geozone] == 'all'
          @geozone_name = t('geozones.none')
        else
          @geozone_name = Geozone.find(params[:geozone]).name
        end
      end

  end
end