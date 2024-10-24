class Admin::BudgetGroups::GroupsComponent < ApplicationComponent
  include Admin::Namespace
  attr_reader :groups

  def initialize(groups)
    @groups = groups
  end

  private

    def budget
      @budget ||= groups.first.budget
    end

    def headings_path(group)
      send("#{namespace}_budget_group_headings_path", group.budget, group)
    end
end
