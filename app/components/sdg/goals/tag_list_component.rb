class SDG::Goals::TagListComponent < ApplicationComponent
  attr_reader :record_or_name, :limit
  delegate :link_list, to: :helpers

  def initialize(record_or_name, limit: nil)
    @record_or_name = record_or_name
    @limit = limit
  end

  def render?
    process.enabled?
  end

  private

    def links
      [*goal_links, see_more_link]
    end

    def goal_links
      goals.limit(limit).map do |goal|
        [
          render(SDG::Goals::IconComponent.new(goal)),
          index_by_goal(goal),
          title: filter_text(goal)
        ]
      end
    end

    def goals
      if record_or_name.respond_to?(:sdg_goals)
        record_or_name.sdg_goals.order(:code)
      else
        SDG::Goal.order(:code)
      end
    end

    def see_more_link
      return unless limit && count_out_of_limit > 0

      [
        "#{count_out_of_limit}+",
        polymorphic_path(record_or_name),
        class: "more-goals", title: t("sdg.goals.filter.more", count: count_out_of_limit)
      ]
    end

    def index_by_goal(goal)
      polymorphic_path(model, advanced_search: { goal: goal.code })
    end

    def filter_text(goal)
      t("sdg.goals.filter.link",
        resources: model.model_name.human(count: :other),
        code: goal.code)
    end

    def count_out_of_limit
      goals.size - limit
    end

    def model
      process.name.constantize
    end

    def process
      @process ||= SDG::ProcessEnabled.new(record_or_name)
    end
end
