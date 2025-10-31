module Statisticable
  extend ActiveSupport::Concern
  PARTICIPATIONS = %w[gender age geozone].freeze

  included do
    attr_reader :resource, :cache
  end

  class_methods do
    def stats_methods
      base_stats_methods + gender_methods + age_methods + geozone_methods
    end

    def base_stats_methods
      %i[total_participants participations] + participation_check_methods
    end

    def participation_check_methods
      PARTICIPATIONS.map { |participation| :"#{participation}?" }
    end

    def gender_methods
      %i[total_male_participants total_female_participants male_percentage female_percentage]
    end

    def age_methods
      [:participants_by_age]
    end

    def geozone_methods
      %i[participants_by_geozone total_no_demographic_data]
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

  def initialize(resource, cache: true)
    @resource = resource
    @cache = cache
  end

  def generate
    User.transaction do
      begin
        define_singleton_method :participants do
          create_participants_table unless participants_table_created?
          participants_class.all
        end

        stats_methods.each { |stat_name| send(stat_name) }
      ensure
        define_singleton_method :participants do
          participants_from_original_table
        end
      end

      drop_participants_table
    end
  end

  def stats_methods
    base_stats_methods + participation_methods
  end

  def participations
    PARTICIPATIONS.select { |participation| send("#{participation}?") }
  end

  def gender?
    participants.male.any? || participants.female.any?
  end

  def age?
    participants.between_ages(
      age_groups.flatten.min,
      age_groups.flatten.max,
      at_time: participation_date
    ).any?
  end

  def geozone?
    participants.where(geozone: geozones).any?
  end

  def participants
    @participants ||= User.unscoped.where(id: participant_ids)
  end
  alias_method :participants_from_original_table, :participants

  def total_male_participants
    participants.male.count
  end

  def total_female_participants
    participants.female.count
  end

  def total_no_demographic_data
    participants.where("gender IS NULL OR date_of_birth IS NULL OR geozone_id IS NULL").count
  end

  def male_percentage
    calculate_percentage(total_male_participants, total_participants_with_gender)
  end

  def female_percentage
    calculate_percentage(total_female_participants, total_participants_with_gender)
  end

  def participants_by_age
    age_groups.to_h do |start, finish|
      count = participants.between_ages(start, finish, at_time: participation_date).count

      [
        "#{start} - #{finish}",
        {
          range: range_description(start, finish),
          count: count,
          percentage: calculate_percentage(count, total_participants)
        }
      ]
    end
  end

  def participants_by_geozone
    geozones.to_h do |geozone|
      count = participants.where(geozone: geozone).count

      [
        geozone.name,
        {
          count: count,
          percentage: calculate_percentage(count, total_participants)
        }
      ]
    end
  end

  def calculate_percentage(fraction, total)
    return 0.0 if total.zero?

    (fraction * 100.0 / total).round(3)
  end

  def advanced?
    resource.advanced_stats_enabled?
  end

  private

    def base_stats_methods
      self.class.base_stats_methods
    end

    def participation_methods
      participations.map { |participation| self.class.send("#{participation}_methods") }.flatten
    end

    def create_participants_table
      User.connection.create_table(
        participants_table_name,
        temporary: true,
        as: participants_from_original_table.to_sql
      )
      User.connection.add_index participants_table_name, :date_of_birth
      User.connection.add_index participants_table_name, :geozone_id
      @participants_table_created = true
    end

    def drop_participants_table
      User.connection.drop_table(participants_table_name, if_exists: true, temporary: true)
      @participants_table_created = false
    end

    def participants_table_name
      @participants_table_name ||= "participants_#{resource.class.table_name}_#{resource.id}"
    end

    def participants_class
      @participants_class ||= Class.new(User).tap { |klass| klass.table_name = participants_table_name }
    end

    def participants_table_created?
      @participants_table_created.present?
    end

    def total_participants_with_gender
      @total_participants_with_gender ||= participants.where.not(gender: nil).distinct.count
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
       [90, 300]]
    end

    def geozones
      Geozone.order(:name)
    end

    def range_description(start, finish)
      if finish > 200
        I18n.t("stats.age_more_than", start: start)
      else
        I18n.t("stats.age_range", start: start, finish: finish)
      end
    end

    def stats_cache(key, &block)
      if cache
        Rails.cache.fetch(full_cache_key_for(key), expires_at: Date.current.end_of_day, &block)
      else
        block.call
      end
    end
end
