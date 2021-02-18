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
        [t("admin.stats.sdg.debates"), goal.debates.count],
        [t("admin.stats.sdg.budget_investments.sent"), goal.budget_investments.count],
        [t("admin.stats.sdg.budget_investments.winners"), goal.budget_investments.winners.count, featured],
        [t("admin.stats.sdg.budget_investments.amount"), amount, featured]
      ]
    end

    def amount
      number_to_currency(goal.budget_investments.winners.sum(:price), precision: 0)
    end

    def featured
      { class: "featured" }
    end
end
