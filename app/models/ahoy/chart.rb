module Ahoy
  class Chart
    attr_reader :event_name
    delegate :count, to: :records
    delegate :t, to: "ApplicationController.helpers"

    def initialize(event_name)
      @event_name = event_name
    end

    def self.active_event_names
      event_names_with_collections.select { |name, collection| collection.any? }.keys.sort_by do |event_name|
        new(event_name).title
      end
    end

    def self.event_names_with_collections
      {
        budget_investment_created: Budget::Investment.with_hidden,
        debate_created: Debate.with_hidden,
        legislation_annotation_created: Legislation::Annotation.with_hidden,
        legislation_answer_created: Legislation::Answer.with_hidden,
        level_3_user: User.with_hidden.level_three_verified,
        proposal_created: Proposal.with_hidden
      }
    end

    def self.active_events_data_points
      ds = Ahoy::DataSource.new

      active_event_names.map { |event_name| new(event_name) }.each do |chart|
        ds.add chart.title, chart.data
      end

      ds.build
    end

    def data_points
      ds = Ahoy::DataSource.new
      ds.add title, data
      ds.build
    end

    def title
      t("admin.stats.graph.#{event_name}")
    end

    def data
      records_by_day.count
    end

    private

      def records
        case event_name.to_sym
        when :budget_investment_supported
          Vote.where(votable_type: "Budget::Investment")
        when :visits
          Visit.all
        else
          self.class.event_names_with_collections[event_name.to_sym]
        end
      end

      def records_by_day
        raise "Unknown event #{event_name}" unless records.respond_to?(:group_by_day)

        records.group_by_day(date_field)
      end

      def date_field
        if event_name.to_sym == :level_3_user
          :verified_at
        else
          :created_at
        end
      end
  end
end
