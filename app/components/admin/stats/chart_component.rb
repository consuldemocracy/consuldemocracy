class Admin::Stats::ChartComponent < ApplicationComponent
  attr_reader :chart

  def initialize(chart)
    @chart = chart
  end

  private

    def count
      chart.count
    end

    def event
      chart.event_name
    end

    def chart_tag
      tag.div("data-graph": admin_api_stats_path(event: event))
    end
end
