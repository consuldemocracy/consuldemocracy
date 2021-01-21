class Admin::Stats::SDGComponent < ApplicationComponent
  include Header

  attr_reader :goals

  def initialize(goals)
    @goals = goals
  end

  private

    def title
      t("admin.stats.sdg.title")
    end
end
