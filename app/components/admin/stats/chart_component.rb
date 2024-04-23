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
      data = nil
      if opt[:id].present?
        data = { opt[:id] => true }
      elsif opt[:event].present?
        data = { event: opt[:event] }
      end
      data
    end
end
