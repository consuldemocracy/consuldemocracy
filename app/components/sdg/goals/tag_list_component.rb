class SDG::Goals::TagListComponent < ApplicationComponent
  attr_reader :record, :limit
  delegate :link_list, to: :helpers

  def initialize(record, limit: nil)
    @record = record
    @limit = limit
  end

  def render?
    SDG::ProcessEnabled.new(record.class.name).enabled?
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
      record.sdg_goals.order(:code)
    end

    def see_more_link
      return unless limit && count_out_of_limit > 0

      [
        "#{count_out_of_limit}+",
        polymorphic_path(record),
        class: "more-goals", title: t("sdg.goals.filter.more", count: count_out_of_limit)
      ]
    end

    def index_by_goal(goal)
      polymorphic_path(record.class, advanced_search: { goal: goal.code })
    end

    def filter_text(goal)
      t("sdg.goals.filter.link",
        resources: record.model_name.human(count: :other),
        code: goal.code)
    end

    def count_out_of_limit
      goals.size - limit
    end
end
