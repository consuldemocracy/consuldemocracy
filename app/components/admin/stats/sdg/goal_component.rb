class Admin::Stats::SDG::GoalComponent < ApplicationComponent
  with_collection_parameter :goal

  attr_reader :goal

  def initialize(goal:)
    @goal = goal
  end

  private

    def stats
      [
        [t("admin.stats.sdg.polls"), goal.polls.count],
        [t("admin.stats.sdg.proposals"), goal.proposals.count],
        [t("admin.stats.sdg.debates"), goal.debates.count]
      ]
    end

    def bugdets_stats
      Budget.order(created_at: :desc).map do |budget|
        [
          budget.name,
          [t("admin.stats.sdg.budget_investments.sent"), sent(budget)],
          [t("admin.stats.sdg.budget_investments.winners"), winners(budget), featured],
          [t("admin.stats.sdg.budget_investments.amount"), amount(budget), featured]
        ]
      end
    end

    def sent(budget)
      investments(budget).count
    end

    def winners(budget)
      investments(budget).winners.count
    end

    def amount(budget)
      number_to_currency(investments(budget).winners.sum(:price), precision: 0)
    end

    def investments(budget)
      goal.budget_investments.by_budget(budget)
    end

    def featured
      { class: "featured" }
    end
end
