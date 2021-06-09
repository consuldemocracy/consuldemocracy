class Admin::BudgetGroups::GroupsComponent < ApplicationComponent
  attr_reader :groups

  def initialize(groups)
    @groups = groups
  end

  private

    def budget
      @budget ||= groups.first.budget
    end

    def headings_path(table_actions_component, group)
      send("#{table_actions_component.namespace}_budget_group_headings_path", group.budget, group)
    end
end
