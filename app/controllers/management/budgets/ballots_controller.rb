class Management::Budgets::BallotsController < Management::BaseController
  before_action :authenticate_user!
  load_and_authorize_resource :budget
  before_action :load_ballot, :load_group, :load_heading, :load_investments


  def new
    load_ballot
    redirect_to management_budget_ballot_path(@budget, @ballot)
  end

  def show
    authorize! :show, @ballot
    render template: "management/budgets/ballots/show"
  end

  # GET-125
  def confirm
    authorize! :confirm, @ballot

    if @ballot.completed?
      if @ballot.build_confirmation_and_commit(current_user, @current_manager.to_s )
        redirect_to management_budget_ballot_path(@budget, @ballot)
      else
        redirect_to management_budget_ballot_path(@budget, @ballot), alert: 'Su votación no se ha podido confirmar'
      end
    end
  end

  def discard
    authorize! :discard, @ballot

    if @ballot.confirmed?
      if @ballot.discard(current_user, @current_manager.to_s )
        redirect_to management_budget_ballot_path(@budget, @ballot), alert: 'Su votación ha sido descartada'
      else
        redirect_to management_budget_ballot_path(@budget, @ballot)
      end
    end
  end

  private

  def load_ballot
    query = Budget::Ballot.where(user: current_user, budget: @budget)
    @ballot = @budget.balloting? ? query.first_or_create : query.first_or_initialize
  end

  #GET-107
  def load_group
    unless @ballot.group.nil?
      @group = @ballot.group
    else
      if params[:group_id]
        @group = @budget.groups.find(params[:group_id])
      end
    end
  end

  def load_heading

    if params[:heading_id]
      @heading = @group.headings.find(params[:heading_id])
    else
      if @group
        @heading = @group.headings.first
      end
    end
  end

  def load_investments
    if @group
      @investments = @budget.investments.where(group_id: @group.id, heading_id: @heading.id).where(selected: true).order('title asc')
    end
  end
end
