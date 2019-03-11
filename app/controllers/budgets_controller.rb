class BudgetsController < ApplicationController
  include FeatureFlags
  include BudgetsHelper
  feature_flag :budgets

  load_and_authorize_resource
  before_action :set_default_budget_filter, only: :show
  has_filters %w{not_unfeasible feasible unfeasible unselected selected}, only: :show

  respond_to :html, :js

  def show
    raise ActionController::RoutingError, 'Not Found' unless budget_published?(@budget)
  end

  def index
    @finished_budgets = @budgets.finished.order(created_at: :desc)
    @budgets_coordinates = current_budget_map_locations
    @banners = Banner.in_section('budgets').with_active
  end

  def results
    if params[:heading_id].present?
      parent = @budget.headings.find(params[:heading_id])
      @heading = parent
      @initial_budget = parent.price
    else
      parent = @budget
      @initial_budget = parent.headings.sum(:price)
    end
    @investments_selected = parent.investments.selected.order(cached_ballots_up: :desc)
  end

  def stats
    @budget = Budget.find(params[:budget_id])
    # @headings = @budget.headings
    stats = {}
    stats[:total_participants] = total_participants
    stats[:total_participants_support_phase] = total_participants_support_phase
    stats[:total_participants_vote_phase] = total_participants_vote_phase
    stats[:total_budgets_investmens] = total_budgets_investmens
    stats[:paper_budgets_invesments] = paper_budgets_invesments
    stats[:total_supports] = total_supports
    stats[:total_votes] = total_votes
    stats[:total_feasible_budgets_investments] = total_feasible_budgets_investments
    stats[:total_unfeasible_budgets_investments] = total_unfeasible_budgets_investments
    stats[:total_male_participants] = total_male_participants
    stats[:total_female_participants] = total_female_participants
    stats[:male_percentage] = male_percentage
    stats[:female_percentage] = female_percentage
    stats[:total_unknown_gender_or_age] = total_unknown_gender_or_age
    stats[:age_groups] = age_groups
    # stats[:headings] = headings
    #
    @stats = stats
  end

  def progress
    @budget = Budget.find(params[:budget_id])
  end

  private

  def participants
    stats_cache("participants_budget_#{@budget.id}") do
      users = (authors + voters + balloters).uniq
      User.where(id: users)
    end
  end

  def total_participants
    stats_cache("total_participants_budget_#{@budget.id}") { participants.distinct.count }
  end

  def stats_cache(key, &block)
    Rails.cache.fetch("budget_investmens_stats/201705160003/#{key}", &block)
  end

  def authors
    # stats_cache('authors') { Budget::Investment.pluck(:author_id) }
    stats_cache("authors_budget_#{@budget.id}") { @budget.investments.pluck(:author_id) }
  end

  def voters
    stats_cache("voters_budget_#{@budget.id}") { ActsAsVotable::Vote.where(votable_type: 'Budget::Investment', votable_id: @budget.investment_ids).pluck(:voter_id) }
  end

  def voters_by_heading(heading_id)
    stats_cache("voters_budget_#{@budget.id}_heading_#{heading_id}") {
      # ActsAsVotable::Vote.where(votable_type: 'SpendingProposal', votable_id: SpendingProposal.by_geozone(geozone_id)).pluck(:voter_id)
      investment_ids = @budget.investments.where(heading_id: heading_id).map(&:id)
      ActsAsVotable::Vote.where(votable_type: 'Budget::Investment', votable_id: investment_ids).pluck(:voter_id)
    }
  end

  def balloters
    stats_cache("balloters_budget_#{@budget.id}") do
      Budget::Ballot::Line.includes(:ballot).where(budget_id: @budget.id).pluck(:user_id)
    end
  end

  def balloters_by_heading(heading_id)
    stats_cache("balloters_budget_#{@budget.id}_heading_#{heading_id}") {
    Budget::Ballot::Line.includes(:ballot).where(budget_id: @budget.id, heading_id: heading_id).pluck(:user_id)
    }
  end

  def total_participants_support_phase
    stats_cache("total_participants_support_phase_budget_#{@budget.id}") {
      voters.uniq.count
    }
  end

  def total_participants_vote_phase
    stats_cache("total_participants_vote_phase_budget_#{@budget.id}") {
      balloters.uniq.count
    }
  end

  def total_budgets_investmens
    #stats_cache('total_budgets_investments') { Budget::Investment.count }
    stats_cache("total_budgets_investments_budget_#{@budget.id}") { @budget.investments.size }
  end

  def paper_budgets_invesments
    0
  end

  def total_supports
    stats_cache("total_supports_budget_#{@budget.id}") {
      ActsAsVotable::Vote.where(votable_type: 'Budget::Investment', votable_id: @budget.investment_ids).count
    }
  end

  def total_votes
    stats_cache("total_votes_budget_#{@budget.id}") {
      Budget::Ballot::Line.count
    }
  end

  def total_feasible_budgets_investments
    #stats_cache('total_feasible_budgets_invesments') { Budget::Investment.feasible.count }
    stats_cache("total_feasible_budgets_invesments_budget_#{@budget.id}") { @budget.investments.feasible.count }
  end

  def total_unfeasible_budgets_investments
    #stats_cache('total_unfeasible_budgets_invesments') { Budget::Investment.unfeasible.count }
    stats_cache("total_unfeasible_budgets_invesments_budget_#{@budget.id}") { @budget.investments.unfeasible.count }
  end

  def total_male_participants
    stats_cache("total_male_participants_budget_#{@budget.id}") { participants.where(gender: 'male').count }
  end

  def total_female_participants
    stats_cache("total_female_participants_budget_#{@budget.id}") { participants.where(gender: 'female').count }
  end

  def male_percentage
    stats_cache("male_percentage_budget_#{@budget.id}") { total_male_participants / total_participants_with_gender.to_f * 100 }
  end

  def female_percentage
    stats_cache("female_percentage_budget_#{@budget.id}") { total_female_participants / total_participants_with_gender.to_f * 100 }
  end

  def total_participants_with_gender
    stats_cache("total_participants_with_gender_budget_#{@budget.id}") { participants.where.not(gender: nil).distinct.count }
  end

  def age_groups
    stats_cache("age_groups_budget_#{@budget.id}") {
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
    }
  end

  def headings
    stats_cache("headings_budget_#{@budget.id}") {
      groups = Hash.new(0)
      @headings.each do |heading|
        groups[heading.id] = Hash.new(0)
        groups[heading.id][:total_participants_support_phase] = voters_by_heading(heading.id).uniq.count
        groups[heading.id][:total_participants_vote_phase]    = balloters_by_heading(heading.id).uniq.count
        groups[heading.id][:total_participants_all_phase]     = (voters_by_heading(heading.id) + balloters_by_heading(heading.id)).uniq.count
      end

      groups[:total] = Hash.new(0)
      groups[:total][:total_participants_support_phase] = groups.collect {|k,v| v[:total_participants_support_phase]}.sum
      groups[:total][:total_participants_vote_phase]    = groups.collect {|k,v| v[:total_participants_vote_phase]}.sum
      groups[:total][:total_participants_all_phase]     = groups.collect {|k,v| v[:total_participants_all_phase]}.sum

      @headings.each do |heading|
        groups[heading.id][:percentage_participants_support_phase]        = voters_by_heading(heading.id).uniq.count / groups[:total][:total_participants_support_phase].to_f * 100
        groups[heading.id][:percentage_district_population_support_phase] = voters_by_heading(heading.id).uniq.count / district_population[heading.name].to_f * 100

        groups[heading.id][:percentage_participants_vote_phase]        = balloters_by_heading(heading.id).uniq.count / groups[:total][:total_participants_vote_phase].to_f * 100
        groups[heading.id][:percentage_district_population_vote_phase] = balloters_by_heading(heading.id).uniq.count / district_population[heading.name].to_f * 100

        groups[heading.id][:percentage_participants_all_phase]        = (voters_by_heading(heading.id) + balloters_by_heading(heading.id)).uniq.count / groups[:total][:total_participants_all_phase].to_f * 100
        groups[heading.id][:percentage_district_population_all_phase] = (voters_by_heading(heading.id) + balloters_by_heading(heading.id)).uniq.count / district_population[heading.name].to_f * 100
      end

      groups[:total][:percentage_participants_support_phase] = groups.collect {|k,v| v[:percentage_participants_support_phase]}.sum
      groups[:total][:percentage_participants_vote_phase]    = groups.collect {|k,v| v[:percentage_participants_vote_phase]}.sum
      groups[:total][:percentage_participants_all_phase]     = groups.collect {|k,v| v[:percentage_participants_all_phase]}.sum

      groups
    }
  end

  def district_population
    { "Tota la ciutat" => 140000 }
  end

  def total_unknown_gender_or_age
    stats_cache("total_unknown_gender_or_age_budget_#{@budget.id}") {
      participants.where("gender IS NULL OR date_of_birth is NULL").uniq.count
    }
  end
  # def delegators
  #   stats_cache('delegators') { User.where.not(representative_id: nil).pluck(:id) }
  # end
end
