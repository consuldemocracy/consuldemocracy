class Flag < ActiveRecord::Base

  belongs_to :user
  belongs_to :flaggable, polymorphic: true, counter_cache: true

  scope(:by_user_and_flaggable, lambda do |user, flaggable|
    where(user_id: user.id,
          flaggable_type: flaggable.class.to_s,
          flaggable_id: flaggable.id)
  end)

  scope(:by_user_and_flaggables, lambda do |user, flaggables|
    return where('FALSE') if flaggables.empty? || user.nil? || user.id.nil?
    where([ "flags.user_id = ? and flags.flaggable_type = ? and flags.flaggable_id IN (?)",
            user.id, flaggables.first.class.name, flaggables.collect(&:id) ])
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
      flags.each{ |flag| @cache[flag.flaggable_id] = true }
      flaggables.each{ |flaggable| @cache[flaggable.id] = !! @cache[flaggable.id] }
    end

    def flagged?(flaggable)
      @cache[flaggable.id]
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
end
