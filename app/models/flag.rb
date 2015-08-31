class Flag < ActiveRecord::Base

  belongs_to :user
  belongs_to :flaggable, polymorphic: true, counter_cache: true

  scope(:by_user_and_flaggable, lambda do |user, flaggable|
    where(user_id: user.id,
          flaggable_type: flaggable.class.to_s,
          flaggable_id: flaggable.id)
  end)

  scope(:by_user_and_flaggables, lambda do |user, flaggables|
    where(build_query_for_user_and_flaggables(user, flaggables))
  end)

  def self.flag!(user, flaggable)
    raise AlreadyFlaggedError if flagged?(user, flaggable)
    create(user: user, flaggable: flaggable)
  end

  def self.unflag!(user, flaggable)
    flags = by_user_and_flaggable(user, flaggable)
    raise NotFlaggedError if flags.empty?
    flags.destroy_all
  end

  def self.flagged?(user, flaggable)
    !! by_user_and_flaggable(user, flaggable).try(:first)
  end

  class Cache
    attr_accessor :user

    def initialize(user, flaggables)
      @user = user
      @cache = {}
      flags = Flag.by_user_and_flaggables(user, flaggables)

      # Fill up the "trues"
      flags.each do |flag|
        @cache[flag.flaggable_type] ||= {}
        @cache[flag.flaggable_type][flag.flaggable_id] = true
      end

      # Fill up the "falses"
      flaggables.each do |flaggable|
        type = flaggable.class.name
        @cache[type] ||= {}
        @cache[type][flaggable.id] = !! @cache[type][flaggable.id]
      end
    end

    def flagged?(flaggable)
      @cache[flaggable.class.name].to_h[flaggable.id]
    end

    def knows?(flaggable)
      flagged?(flaggable) != nil
    end
  end

  class AlreadyFlaggedError < StandardError
    def initialize
      super "The flaggable was already flagged by this user"
    end
  end

  class NotFlaggedError < StandardError
    def initialize
      super "The flaggable was not flagged by this user"
    end
  end

  private
    def self.build_query_for_user_and_flaggables(user, flaggables)
      return ['FALSE'] if flaggables.empty?

      ids_by_type = {}
      flaggables.each do |flaggable|
        type = flaggable.class.name
        ids_by_type[type] ||= []
        ids_by_type[type] << flaggable.id
      end

      query_strings = []
      query_values = []
      ids_by_type.each do |type, ids|
        query_strings << "(flags.flaggable_type = ? AND flags.flaggable_id IN (?))"
        query_values << type << ids
      end
      query_string = "(flags.user_id = ?) AND (#{query_strings.join(' OR ')})"
      [query_string, user.id] + query_values
    end
end
