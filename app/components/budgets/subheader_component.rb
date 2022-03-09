class Budgets::SubheaderComponent < ApplicationComponent
  delegate :current_user, :link_to_signin, :link_to_signup, :link_to_verify_account, :can?, to: :helpers
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end
end
