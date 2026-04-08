class Admin::Events::IndexComponent < ApplicationComponent
  include Header

  attr_reader :events

  def initialize(events)
    @events = events
  end

  private

    def title
      t("admin.events.index.title")
    end
end
