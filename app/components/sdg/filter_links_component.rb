class SDG::FilterLinksComponent < ApplicationComponent
  attr_reader :records, :related_model, :see_more_link
  delegate :link_list, to: :helpers

  def initialize(records, related_model, see_more_link: nil)
    @records = records
    @related_model = related_model
    @see_more_link = see_more_link
  end

  def links
    [*sdg_links, see_more_link]
  end

  private

    def sdg_links
      records.map do |goal_or_target|
        [
          render(SDG::TagComponent.new(goal_or_target)),
          index_by(parameter_name => goal_or_target.code),
          title: filter_text(goal_or_target),
          data: { code: goal_or_target.code }
        ]
      end
    end

    def filter_text(goal_or_target)
      t("sdg.#{i18n_namespace}.filter.link",
        resources: related_model.model_name.human(count: :other),
        code: goal_or_target.code)
    end

    def index_by(advanced_search)
      polymorphic_path(related_model, advanced_search: advanced_search)
    end

    def i18n_namespace
      parameter_name.pluralize
    end

    def parameter_name
      if records.first.is_a?(SDG::Goal)
        "goal"
      else
        "target"
      end
    end
end
