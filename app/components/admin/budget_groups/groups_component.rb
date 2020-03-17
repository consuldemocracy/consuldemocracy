class Admin::BudgetGroups::GroupsComponent < ApplicationComponent
  attr_reader :groups

  def initialize(groups)
    @groups = groups
  end

  private

    def budget
      @budget ||= groups.first.budget
    end
end
