class BudgetsController < ApplicationController
  include FeatureFlags
  feature_flag :budgets

  load_and_authorize_resource
  before_action :set_default_budget_filter, only: :show
  has_filters %w{not_unfeasible feasible unfeasible unselected selected}, only: :show

  respond_to :html, :js

  def show
  end

  def index
    @budgets = @budgets.visible.order(:created_at)
  end

  def results
    if params[:group_id]
      @group = @budget.groups.find(params[:group_id])
    end

    @ballots = @budget.ballots.where.not(user_id: nil).joins(:user).where('users.verified_at IS NOT NULL').order('created_at desc')

    @all_confirmations_on_budget = Budget::Ballot::Confirmation.where(budget_id: @budget.id, discarted_at: nil)
                             .joins(:ballot)
                             .joins('LEFT JOIN budget_ballot_lines ON budget_ballots.id = budget_ballot_lines.ballot_id')
                             .uniq('budget_ballot_confirmations.id')

    @valid_confirmations_on_budget = Budget::Ballot::Confirmation.where(budget_id: @budget.id, discarted_at: nil).where.not(confirmed_at: nil)
                                       .joins(:ballot)
                                       .joins('LEFT JOIN budget_ballot_lines ON budget_ballots.id = budget_ballot_lines.ballot_id')
                                       .uniq('budget_ballot_confirmations.id')

    @not_valid_confirmations_on_budget = Budget::Ballot::Confirmation.where(budget_id: @budget.id, discarted_at: nil).where(confirmed_at: nil)
                                         .joins(:ballot)
                                         .joins('LEFT JOIN budget_ballot_lines ON budget_ballots.id = budget_ballot_lines.ballot_id')
                                         .uniq('budget_ballot_confirmations.id')

    @not_verified = @budget.ballots.where.not(user_id: nil)
                        .joins(:user)
                        .where('users.verified_at IS NOT NULL').order('created_at desc')

    @not_sms_sent_ballots_on_budget =  @budget.not_sent_participant_count - @valid_confirmations_on_budget.count - @not_valid_confirmations_on_budget.count

    if @group


      @all_confirmations = Budget::Ballot::Confirmation.where(budget_id: @budget.id, discarted_at: nil, group_id: @group.id)
                               .joins(:ballot)
                               .joins('LEFT JOIN budget_ballot_lines ON budget_ballots.id = budget_ballot_lines.ballot_id')
                               .uniq('budget_ballot_confirmations.id')

      @all_confirmations = Budget::Ballot::Confirmation.where(budget_id: @budget.id, discarted_at: nil, group_id: @group.id)
                           .joins(:ballot)
                           .joins('LEFT JOIN budget_ballot_lines ON budget_ballots.id = budget_ballot_lines.ballot_id')
                           .uniq('budget_ballot_confirmations.id')

      @valid_confirmations = Budget::Ballot::Confirmation.where(budget_id: @budget.id, discarted_at: nil, group_id: @group.id)
                           .where.not(confirmed_at: nil)
                           .joins(:ballot)
                           .joins('LEFT JOIN budget_ballot_lines ON budget_ballots.id = budget_ballot_lines.ballot_id')
                           .uniq('budget_ballot_confirmations.id')

      @not_valid_confirmations = Budget::Ballot::Confirmation.where(budget_id: @budget.id, discarted_at: nil, group_id: @group.id)
                           .where(confirmed_at: nil)
                           .joins(:ballot)
                           .joins('LEFT JOIN budget_ballot_lines ON budget_ballots.id = budget_ballot_lines.ballot_id')
                           .uniq('budget_ballot_confirmations.id')
      
    else

      @headings_by_name = @budget.headings.group(:name).select(:name).collect { |h| [h.name, @budget.headings.where(name: h.name).pluck(:id)] }.to_h
    end

  end
end
