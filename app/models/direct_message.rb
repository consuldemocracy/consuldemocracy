class DirectMessage < ActiveRecord::Base
  belongs_to :sender,   class_name: 'User', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'

  validates :title,    presence: true
  validates :body,     presence: true
  validates :sender,   presence: true
  validates :receiver, presence: true
  validate  :max_per_day

  scope :today, lambda { where('DATE(created_at) = DATE(?)', Time.current) }

  def max_per_day
    return if errors.any?
    max = Setting[:direct_message_max_per_day]
    return unless max

    if sender.direct_messages_sent.today.count >= max.to_i
      errors.add(:title, I18n.t('activerecord.errors.models.direct_message.attributes.max_per_day.invalid'))
    end
  end

end

# == Schema Information
#
# Table name: direct_messages
#
#  id          :integer          not null, primary key
#  sender_id   :integer
#  receiver_id :integer
#  title       :string
#  body        :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
