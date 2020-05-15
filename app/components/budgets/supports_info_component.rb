class Budgets::SupportsInfoComponent < ApplicationComponent
  delegate :current_user, to: :helpers
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  def render?
    budget.selecting?
  end

  private

    def support_info_heading
      if current_user
        sanitize(t("budgets.supports_info.supported", count: total_supports))
      else
        sanitize(t("budgets.supports_info.supported_not_logged_in"))
      end
    end

    def total_supports
      Vote.where(votable: budget.investments, voter: current_user).count
    end
end
