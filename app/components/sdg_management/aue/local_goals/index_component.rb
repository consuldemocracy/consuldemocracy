class SDGManagement::AUE::LocalGoals::IndexComponent < ApplicationComponent
  include Header

  attr_reader :local_goals

  def initialize(local_goals)
    @local_goals = local_goals
  end

  private

    def title
      AUE::LocalGoal.model_name.human(count: 2).titleize
    end

    def attribute_name(attribute)
      AUE::LocalGoal.human_attribute_name(attribute)
    end

    def header_id(object)
      "#{dom_id(object)}_header"
    end

    def actions(local_goal)
      render Admin::TableActionsComponent.new(local_goal)
    end
end
