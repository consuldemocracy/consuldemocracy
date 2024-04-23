module Ahoy
  class Chart
    attr_reader :event_name
    delegate :count, :group_by_day, to: :events

    def initialize(event_name)
      @event_name = event_name
    end

    def self.active_event_names
      Ahoy::Event.distinct.order(:name).pluck(:name)
    end

    private

      def events
        Ahoy::Event.where(name: event_name)
      end
  end
end
