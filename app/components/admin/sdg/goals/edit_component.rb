class Admin::SDG::Goals::EditComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  attr_reader :goal

  def initialize(goal)
    @goal = goal
  end

  def title
    t("admin.sdg.goals.edit.title", code: goal.code, title: goal.title)
  end
end
