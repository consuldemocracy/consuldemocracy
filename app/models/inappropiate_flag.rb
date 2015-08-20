class InappropiateFlag < ActiveRecord::Base

  belongs_to :user
  belongs_to :flaggable, polymorphic: true, counter_cache: true, touch: :flagged_as_inappropiate_at

  scope(:by_user_and_flaggable, lambda do |user, flaggable|
    where(user_id: user.id,
          flaggable_type: flaggable.class.to_s,
          flaggable_id: flaggable.id)
  end)


  class AlreadyFlaggedError < StandardError
    def initialize
      super "The flaggable was already flagged as inappropiate by this user"
    end
  end

  class NotFlaggedError < StandardError
    def initialize
      super "The flaggable was not flagged as inappropiate by this user"
    end
  end


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
    by_user_and_flaggable(user, flaggable).exists?
  end

end
