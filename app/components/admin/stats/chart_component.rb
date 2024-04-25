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
      tag.div("data-graph": chart.data_points.to_json)
    end

    def title
      "#{chart.title} (#{count})"
    end
end
