class Admin::Stats::EventLinksComponent < ApplicationComponent
  attr_reader :event_names

  def initialize(event_names)
    @event_names = event_names
  end

  private

    def link_text(event)
      text = t("admin.stats.graph.#{event}")
      if text.to_s.match(/translation missing/)
        text = event
      end
      text
    end
end
