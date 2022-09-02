class SDGManagement::AUE::LocalGoals::FormComponent < ApplicationComponent
  include Header
  include TranslatableFormHelper
  include GlobalizeHelper

  attr_reader :local_goal

  def initialize(local_goal)
    @local_goal = local_goal
  end

  private

    def title
      if local_goal.persisted?
        t("sdg_management.local_goals.edit.title")
      else
        t("sdg_management.local_goals.new.title")
      end
    end

    def form_url
      if local_goal.persisted?
        sdg_management_aue_local_goal_path(local_goal)
      else
        sdg_management_aue_local_goals_path
      end
    end

end
