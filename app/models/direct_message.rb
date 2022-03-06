class DirectMessage < ApplicationRecord
  belongs_to :sender,   class_name: "User", inverse_of: :direct_messages_sent
  belongs_to :receiver, class_name: "User", inverse_of: :direct_messages_received

  validates :title,    presence: true
  validates :body,     presence: true
  validates :sender,   presence: true
  validates :receiver, presence: true
  validate  :max_per_day

  scope :today, lambda { where(created_at: Date.current.all_day) }

  def max_per_day
    return if errors.any?

    max = Setting[:direct_message_max_per_day]
    return unless max

    if sender.direct_messages_sent.today.count >= max.to_i
      errors.add(:title, I18n.t("activerecord.errors.models.direct_message.attributes.max_per_day.invalid"))
    end
  end
end
