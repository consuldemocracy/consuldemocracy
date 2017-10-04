class SpendingProposalsController < ApplicationController
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

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  respond_to :html, :js

  def index
    @spending_proposals = apply_filters_and_search(SpendingProposal).send("sort_by_#{@current_order}", params[:random_seed]).page(params[:page]).per(10).for_render
    set_spending_proposal_votes(@spending_proposals)
  end

  def welcome
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
    if current_user.pending_delegation_alert?
      current_user.update(accepted_delegation_alert: true, representative: nil)
      @accepted_delegation_alert = true
    end
  end

  def stats
    @geozones = Geozone.order(:name)
    stats = {}
    stats[:total_participants] = total_participants
    stats[:total_participants_support_phase] = total_participants_support_phase
    stats[:total_participants_vote_phase] = total_participants_vote_phase
    stats[:total_spending_proposals] = total_spending_proposals
    stats[:paper_spending_proposals] = paper_spending_proposals
    stats[:total_supports] = total_supports
    stats[:total_votes] = total_votes
    stats[:total_feasible_spending_proposals] = total_feasible_spending_proposals
    stats[:total_unfeasible_spending_proposals] = total_unfeasible_spending_proposals
    stats[:total_male_participants] = total_male_participants
    stats[:total_female_participants] = total_female_participants
    stats[:male_percentage] = male_percentage
    stats[:female_percentage] = female_percentage
    stats[:age_groups] = age_groups
    stats[:geozones] = geozones
    stats[:total_unknown_gender_or_age] = total_unknown_gender_or_age

    @stats = stats
  end

  def results
    @geozone = daily_cache("geozone_geozone_#{params[:geozone_id]}") { params[:geozone_id].blank? || params[:geozone_id] == 'all' ? nil : Geozone.find(params[:geozone_id]) }
    @delegated_ballots = daily_cache("delegated_geozone_#{params[:geozone_id]}") { Forum.delegated_ballots }
    @spending_proposals = daily_cache("sps_geozone_#{params[:geozone_id]}") { SpendingProposal.feasible.compatible.valuation_finished.by_geozone(params[:geozone_id]) }
    @spending_proposals = daily_cache("sorted_sps_geozone_#{params[:geozone_id]}") { SpendingProposal.sort_by_delegated_ballots_and_price(@spending_proposals, @delegated_ballots) }

    @initial_budget = daily_cache("initial_budget_geozone_#{params[:geozone_id]}") { Ballot.initial_budget(@geozone) }
    @incompatibles = daily_cache("incompatibles_geozone_#{params[:geozone_id]}") { SpendingProposal.incompatible.by_geozone(params[:geozone_id]) }
  end

  private

    def daily_cache(key, &block)
      Rails.cache.fetch("spending_proposals_results/#{Time.now.strftime('%Y-%m-%d')}/#{key}", &block)
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
      target = target.by_geozone(params[:geozone]) if params[:unfeasible].blank?
      set_filter_geozone

      target = target.by_forum if params[:forum].present?
      target = target.search(params[:search]) if params[:search].present?
      target
    end

    def set_random_seed
      if params[:order] == 'random' || params[:order].blank?
        params[:random_seed] ||= rand(99) / 100.0
        seed = begin
                 Float(params[:random_seed])
               rescue
                 0
               end
        SpendingProposal.connection.execute "select setseed(#{seed})"
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

    def total_participants_with_gender
      stats_cache('total_participants_with_gender') { participants.where.not(gender: nil).distinct.count }
    end

    def participants
      stats_cache('participants') do
        users = (authors + voters + balloters + delegators).uniq
        User.where(id: users)
      end
    end

    def total_participants_support_phase
      stats_cache('total_participants_support_phase') do
        voters.uniq.count
      end
    end

    def total_participants_vote_phase
      stats_cache('total_participants_vote_phase') do
        balloters.uniq.count
      end
    end

    def total_supports
      stats_cache('total_supports') do
        ActsAsVotable::Vote.where(votable_type: 'SpendingProposal').count
      end
    end

    def total_votes
      stats_cache('total_votes') do
        BallotLine.count
      end
    end

    def authors
      stats_cache('authors') { SpendingProposal.pluck(:author_id) }
    end

    def voters
      stats_cache('voters') { ActsAsVotable::Vote.where(votable_type: 'SpendingProposal').pluck(:voter_id) }
    end

    def voters_by_geozone(geozone_id)
      stats_cache("voters_geozone_#{geozone_id}") do
        ActsAsVotable::Vote.where(votable_type: 'SpendingProposal', votable_id: SpendingProposal.by_geozone(geozone_id)).pluck(:voter_id)
      end
    end

    def balloters
      stats_cache('balloters') do
        Ballot.where('ballot_lines_count > ?', 0).pluck(:user_id)
      end
    end

    def balloters_by_geozone(geozone_id)
      stats_cache("balloters_geozone_#{geozone_id}") do
        Ballot.where('ballot_lines_count > ? AND geozone_id = ?', 0, geozone_id).pluck(:user_id)
      end
    end

    def delegators
      stats_cache('delegators') { User.where.not(representative_id: nil).pluck(:id) }
    end

    def total_spending_proposals
      stats_cache('total_spending_proposals') { SpendingProposal.count }
    end

    def paper_spending_proposals
      112
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
      stats_cache('male_percentage') { total_male_participants / total_participants_with_gender.to_f * 100 }
    end

    def female_percentage
      stats_cache('female_percentage') { total_female_participants / total_participants_with_gender.to_f * 100 }
    end

    def age_groups
      stats_cache('age_groups') do
        groups = Hash.new(0)
        ["16 - 19",
         "20 - 24",
         "25 - 29",
         "30 - 34",
         "35 - 39",
         "40 - 44",
         "45 - 49",
         "50 - 54",
         "55 - 59",
         "60 - 64",
         "65 - 69",
         "70 - 140"].each do |group|
          start, finish = group.split(" - ")
          group_name = (group == "70 - 140" ? "+ 70" : group)
          groups[group_name] = User.where(id: participants).where("date_of_birth > ? AND date_of_birth < ?", finish.to_i.years.ago.beginning_of_year, eval(start).years.ago.end_of_year).count
        end
        groups
      end
    end

    def geozones
      stats_cache('geozones') do
        groups = Hash.new(0)
        @geozones.each do |geozone|
          groups[geozone.id] = Hash.new(0)
          groups[geozone.id][:total_participants_support_phase] = voters_by_geozone(geozone.id).uniq.count
          groups[geozone.id][:total_participants_vote_phase]    = balloters_by_geozone(geozone.id).uniq.count
          groups[geozone.id][:total_participants_all_phase]     = (voters_by_geozone(geozone.id) + balloters_by_geozone(geozone.id)).uniq.count
        end

        groups[:total] = Hash.new(0)
        groups[:total][:total_participants_support_phase] = groups.collect {|_k, v| v[:total_participants_support_phase]}.sum
        groups[:total][:total_participants_vote_phase]    = groups.collect {|_k, v| v[:total_participants_vote_phase]}.sum
        groups[:total][:total_participants_all_phase]     = groups.collect {|_k, v| v[:total_participants_all_phase]}.sum

        @geozones.each do |geozone|
          groups[geozone.id][:percentage_participants_support_phase]        = voters_by_geozone(geozone.id).uniq.count / groups[:total][:total_participants_support_phase].to_f * 100
          groups[geozone.id][:percentage_district_population_support_phase] = voters_by_geozone(geozone.id).uniq.count / district_population[geozone.name].to_f * 100

          groups[geozone.id][:percentage_participants_vote_phase]        = balloters_by_geozone(geozone.id).uniq.count / groups[:total][:total_participants_vote_phase].to_f * 100
          groups[geozone.id][:percentage_district_population_vote_phase] = balloters_by_geozone(geozone.id).uniq.count / district_population[geozone.name].to_f * 100

          groups[geozone.id][:percentage_participants_all_phase]        = (voters_by_geozone(geozone.id) + balloters_by_geozone(geozone.id)).uniq.count / groups[:total][:total_participants_all_phase].to_f * 100
          groups[geozone.id][:percentage_district_population_all_phase] = (voters_by_geozone(geozone.id) + balloters_by_geozone(geozone.id)).uniq.count / district_population[geozone.name].to_f * 100
        end

        groups[:total][:percentage_participants_support_phase] = groups.collect {|_k, v| v[:percentage_participants_support_phase]}.sum
        groups[:total][:percentage_participants_vote_phase]    = groups.collect {|_k, v| v[:percentage_participants_vote_phase]}.sum
        groups[:total][:percentage_participants_all_phase]     = groups.collect {|_k, v| v[:percentage_participants_all_phase]}.sum

        groups
      end
    end

    def district_population
      { "Arganzuela"          => 131429,
        "Barajas"             =>  37725,
        "Carabanchel"         => 205197,
        "Centro"              => 120867,
        "Chamartín"           => 123099,
        "Chamberí"            => 122280,
        "Ciudad Lineal"       => 184285,
        "Fuencarral-El Pardo" => 194232,
        "Hortaleza"           => 146471,
        "Latina"              => 204427,
        "Moncloa-Aravaca"     =>  99274,
        "Moratalaz"           =>  82741,
        "Puente de Vallecas"  => 194314,
        "Retiro"              => 103666,
        "Salamanca"           => 126699,
        "San Blas-Canillejas" => 127800,
        "Tetuán"              => 133972,
        "Usera"               => 112158,
        "Vicálvaro"           =>  55783,
        "Villa de Vallecas"   =>  82504,
        "Villaverde"          => 117478 }
    end

    def total_unknown_gender_or_age
      stats_cache('total_unknown_gender_or_age') do
        participants.where("gender IS NULL OR date_of_birth is NULL").uniq.count
      end
    end

    def stats_cache(key, &block)
      Rails.cache.fetch("spending_proposals_stats/201607131316/#{key}", &block)
    end

end
