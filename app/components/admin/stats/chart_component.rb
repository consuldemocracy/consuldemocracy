class Admin::Stats::ChartComponent < ApplicationComponent
  attr_reader :name, :event, :count

  def initialize(name:, event:, count:)
    @name = name
    @event = event
    @count = count
  end

  private

    def chart_tag(opt = {})
      opt[:data] ||= {}
      opt[:data][:graph] = admin_api_stats_path(chart_data(opt))
      tag.div(**opt)
    end

    def chart_data(opt = {})
      if opt[:id].present?
        { opt[:id] => true }
      elsif opt[:event].present?
        { event: opt[:event] }
      end
    end
end
