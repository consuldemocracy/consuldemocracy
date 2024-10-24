class Admin::Stats::GlobalChartComponent < ApplicationComponent
  private

    def event_names
      Ahoy::Chart.active_event_names
    end

    def chart_tag
      tag.div("data-graph": data_points.to_json)
    end

    def data_points
      Ahoy::Chart.active_events_data_points
    end

    def title
      t("admin.stats.graph.title")
    end
end
