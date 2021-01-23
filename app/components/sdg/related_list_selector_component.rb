class SDG::RelatedListSelectorComponent < ApplicationComponent
  attr_reader :f

  def initialize(form)
    @f = form
  end

  def checked?(code)
    f.object.sdg_goals.find_by(code: code).present?
  end

  def sdg_related_suggestions
    goals_and_targets.map { |goal_or_target| suggestion_tag_for(goal_or_target) }
  end

  def goals_and_targets
    goals.map do |goal|
      global_and_local_targets = goal.targets + goal.local_targets
      [goal, global_and_local_targets.sort]
    end.flatten
  end

  def suggestion_tag_for(goal_or_target)
    {
      tag: "#{goal_or_target.code}. #{goal_or_target.title.gsub(",", "")}",
      display_text: text_for(goal_or_target),
      title: goal_or_target.title,
      value: goal_or_target.code
    }
  end

  def render?
    SDG::ProcessEnabled.new(f.object).enabled?
  end

  private

    def goals
      SDG::Goal.order(:code)
    end

    def text_for(goal_or_target)
      if goal_or_target.class.name == "SDG::Goal"
        t("sdg.related_list_selector.goal_identifier", code: goal_or_target.code)
      else
        goal_or_target.code
      end
    end
end
