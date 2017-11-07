class BudgetPollsController < ApplicationController

  skip_authorization_check

  def show
    redirect_to new_budget_poll_path
  end

  def new
    @budget_poll = BudgetPoll.new
  end

  def create
    @budget_poll = BudgetPoll.create(budget_poll_params)

    if @budget_poll.save
      redirect_to thanks_budget_poll_path
    else
      render :new
    end
  end

  def thanks
  end

  private

    def budget_poll_params
      params.require(:budget_poll).permit(:name, :email, :preferred_subject, :collective, :public_worker, :proposal_author, :selected_proposal_author)
    end
end
