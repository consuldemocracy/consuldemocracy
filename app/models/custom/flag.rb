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
    puts("flag id is ",flaggable.id, flaggable)
    create!(user: user, flaggable: flaggable)
      alert_title = "Moderation alert"
      alert_body = "An item has been flagged for moderation"
      alert_link = "/moderation"
      admin_notification = AdminNotification.new(title: alert_title, body: alert_body, segment_recipient: "administrators", link: "/moderation/comments")
      admin_notification.save
      admin_notification.deliver
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
