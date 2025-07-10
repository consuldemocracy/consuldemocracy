class Flag < ApplicationRecord
  belongs_to :user
  belongs_to :flaggable, polymorphic: true, counter_cache: true, touch: true

  scope(:by_user_and_flaggable, lambda do |user, flaggable|
    where(user_id: user.id,
          flaggable_type: flaggable.class.to_s,
          flaggable_id: flaggable.id)
  end)

  scope :for_comments, ->(comments) { where(flaggable_type: "Comment", flaggable_id: comments) }

  def self.flag(user, flaggable)
    return false if flagged?(user, flaggable)

    create!(user: user, flaggable: flaggable)
  end

  def self.unflag(user, flaggable)
    flags = by_user_and_flaggable(user, flaggable)
    return false if flags.empty?

    flags.destroy_all
  end

  def self.flagged?(user, flaggable)
    return false unless user

    !!by_user_and_flaggable(user, flaggable)&.first
  end
end
