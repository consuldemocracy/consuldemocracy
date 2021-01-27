module SDG::TagList
  extend ActiveSupport::Concern
  attr_reader :record_or_name, :limit
  delegate :link_list, to: :helpers

  def initialize(record_or_name, limit: nil)
    @record_or_name = record_or_name
    @limit = limit
  end

  def render?
    process.enabled?
  end

  def see_more_link(collection)
    count = count_out_of_limit(collection)

    if count > 0
      [
        "#{count}+",
        polymorphic_path(record),
        class: "more-#{i18n_namespace}", title: t("sdg.#{i18n_namespace}.filter.more", count: count)
      ]
    end
  end

  def filter_text(goal_or_target)
    t("sdg.#{i18n_namespace}.filter.link",
      resources: model.model_name.human(count: :other),
      code: goal_or_target.code)
  end

  def index_by(advanced_search)
    polymorphic_path(model, advanced_search: advanced_search)
  end

  def count_out_of_limit(collection)
    return 0 unless limit

    collection.size - limit
  end

  def process
    @process ||= SDG::ProcessEnabled.new(record_or_name)
  end

  def model
    process.name.constantize
  end
end
