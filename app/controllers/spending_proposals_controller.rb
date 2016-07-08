class SpendingProposalsController < ApplicationController
  include FeatureFlags
  include CommentableActions
  include FlagActions

  before_action :authenticate_user!, except: [:index, :welcome, :show, :select_district, :stats, :results]
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
    stats = {}
    stats[:total_participants] = total_participants
    stats[:total_spending_proposals] = total_spending_proposals
    stats[:total_feasible_spending_proposals] = total_feasible_spending_proposals
    stats[:total_unfeasible_spending_proposals] = total_unfeasible_spending_proposals
    stats[:total_male_participants] = total_male_participants
    stats[:total_female_participants] = total_female_participants
    stats[:male_percentage] = male_percentage
    stats[:female_percentage] = female_percentage
    stats[:age_groups] = age_groups

    @stats = stats
    @geozones = Geozone.order(:name)
  end

  def results
    @geozone = daily_cache("geozone_geozone_#{params[:geozone_id]}") { (params[:geozone_id].blank? || params[:geozone_id] == 'all') ? nil : Geozone.find(params[:geozone_id]) }
    @delegated_ballots = daily_cache("delegated_geozone_#{params[:geozone_id]}") { Forum.delegated_ballots }
    @spending_proposals = daily_cache("sps_geozone_#{params[:geozone_id]}") { SpendingProposal.feasible.compatible.valuation_finished.by_geozone(params[:geozone_id]) }
    @spending_proposals = daily_cache("sorted_sps_geozone_#{params[:geozone_id]}") { SpendingProposal.sort_by_delegated_ballots_and_price(@spending_proposals, @delegated_ballots) }

    @initial_budget = daily_cache("initial_budget_geozone_#{params[:geozone_id]}") { Ballot.initial_budget(@geozone) }
    @incompatibles = daily_cache("incompatibles_geozone_#{params[:geozone_id]}") { SpendingProposal.incompatible.by_geozone(params[:geozone_id]) }
  end

  private

    def daily_cache(key, &block)
      Rails.cache.fetch("spending_proposals_results/#{Time.now.strftime("%Y-%m-%d")}/#{key}", &block)
    end

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

    def total_participants
      stats_cache('total_participants') { participants.distinct.count }
    end

    def participants
      stats_cache('participants') {

        users = (authors + voters + balloters + delegators + commentators).uniq
        User.where(id: users)
      }
    end

    def authors
      stats_cache('authors') { SpendingProposal.pluck(:author_id) }
    end

    def voters
      stats_cache('voters') { ActsAsVotable::Vote.where(votable_type: 'SpendingProposal').pluck(:voter_id) }
    end

    def balloters
      stats_cache('balloters') { Ballot.where('ballot_lines_count > ?', 0).pluck(:user_id) }
    end

    def delegators
      stats_cache('delegators') { User.where.not(representative_id: nil).pluck(:id) }
    end

    def commentators
      stats_cache('commentators') { Comment.where(commentable_type: 'SpendingProposal').pluck(:user_id) }
    end

    def total_spending_proposals
      stats_cache('total_spending_proposals') { SpendingProposal.count }
    end

    def total_feasible_spending_proposals
      stats_cache('total_feasible_spending_proposals') { SpendingProposal.feasible.count }
    end

    def total_unfeasible_spending_proposals
      stats_cache('total_unfeasible_spending_proposals') { SpendingProposal.unfeasible.count }
    end

    def total_male_participants
      stats_cache('total_male_participants') { participants.where(gender: 'male').count }
    end

    def total_female_participants
      stats_cache('total_female_participants') { participants.where(gender: 'female').count }
    end

    def male_percentage
      stats_cache('male_percentage') { total_male_participants / total_participants.to_f * 100 }
    end

    def female_percentage
      stats_cache('female_percentage') { total_female_participants / total_participants.to_f * 100 }
    end

    def age(dob)
      now = Time.now.utc.to_date
      now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
    end

    def age_group(dob)
      user_age = age(dob)

      if (16..19).include?(user_age)
        "16 - 19"
      elsif (20..24).include?(user_age)
        "20 - 24"
      elsif (25..29).include?(user_age)
        "25 - 29"
      elsif (30..34).include?(user_age)
        "30 - 34"
      elsif (35..39).include?(user_age)
        "35 - 39"
      elsif (40..44).include?(user_age)
        "40 - 44"
      elsif (45..49).include?(user_age)
        "45 - 49"
      elsif (50..54).include?(user_age)
        "50 - 54"
      elsif (55..59).include?(user_age)
        "55 - 59"
      elsif (60..64).include?(user_age)
        "60 - 64"
      elsif (65..69).include?(user_age)
        "65 - 69"
      elsif (70..120).include?(user_age)
        "+ 70"
      else
        puts "Cannot determine age group for dob: #{dob} and age: #{age(dob)}"
        "Unknown"
      end
    end

    def age_groups
      groups = Hash.new(0)
      participants.find_each do |participant|
        if participant.date_of_birth.present?
          groups[age_group(participant.date_of_birth)] += 1
        end
      end
      groups
    end

    def stats_cache(key, &block)
      Rails.cache.fetch("spending_proposals_stats/#{Time.now}/#{key}", &block)
    end

end