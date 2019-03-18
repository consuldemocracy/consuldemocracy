module Statisticable
  extend ActiveSupport::Concern

  included do
    attr_reader :resource

    def initialize(resource)
      @resource = resource
    end

    def generate
      self.class.stats_methods.each { |stat_name| send(stat_name) }
    end

    def total_male_participants
      participants.male.count
    end

    def total_female_participants
      participants.female.count
    end

    def total_unknown_gender_or_age
      participants.where("gender IS NULL OR date_of_birth is NULL").uniq.count
    end

    def male_percentage
      calculate_percentage(total_male_participants, total_participants_with_gender)
    end

    def female_percentage
      calculate_percentage(total_female_participants, total_participants_with_gender)
    end

    def participants_by_age
      age_groups.map do |start, finish|
        count = participants.between_ages(start, finish).count

        [
          "#{start} - #{finish}",
          {
            range: range_description(start, finish),
            count: count,
            percentage: calculate_percentage(count, total_participants)
          }
        ]
      end.to_h
    end

    def participants_by_geozone
      geozones.map do |geozone|
        count = participants.where(geozone: geozone).count

        [
          geozone.name,
          {
            total: {
              count: count,
              percentage: calculate_percentage(count, total_participants)
            },
            percentage: calculate_percentage(count, geozone.users.count)
          }
        ]
      end.to_h
    end

    private

      def total_participants_with_gender
        participants.where.not(gender: nil).distinct.count
      end

      def age_groups
        [[16, 19],
         [20, 24],
         [25, 29],
         [30, 34],
         [35, 39],
         [40, 44],
         [45, 49],
         [50, 54],
         [55, 59],
         [60, 64],
         [65, 69],
         [70, 74],
         [75, 79],
         [80, 84],
         [85, 89],
         [90, 300]
        ]
      end

      def participants_between_ages(from, to)
        participants.between_ages(from, to)
      end

      def geozones
        Geozone.all.order("name")
      end

      def calculate_percentage(fraction, total)
        return 0.0 if total.zero?

        (fraction * 100.0 / total).round(3)
      end

      def range_description(start, finish)
        if finish > 200
          I18n.t("stats.age_more_than", start: start)
        else
          I18n.t("stats.age_range", start: start, finish: finish)
        end
      end
  end

  class_methods do
    def stats_methods
      %i[total_participants
         total_male_participants total_female_participants total_unknown_gender_or_age
         male_percentage female_percentage
         participants_by_age participants_by_geozone]
    end

    def stats_cache(*method_names)
      method_names.each do |method_name|
        alias_method :"raw_#{method_name}", method_name

        define_method method_name do
          stats_cache(method_name) { send(:"raw_#{method_name}") }
        end
      end
    end
  end
end
