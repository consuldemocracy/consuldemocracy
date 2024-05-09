class Admin::Stats::EventLinksComponent < ApplicationComponent
  attr_reader :event_names
  use_helpers :link_list

  def initialize(event_names)
    @event_names = event_names
  end

  private

    def link_text(event)
      Ahoy::Chart.new(event).title
    end

    def links
      event_names.map do |event|
        [link_text(event), graph_admin_stats_path(event: event)]
      end
    end
end
