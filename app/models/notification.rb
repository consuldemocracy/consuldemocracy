class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  scope :unread, -> { all }
  scope :recent, -> { order(id: :desc) }
  scope :for_render, -> { includes(notifiable: [:user]) }

  def username
    notifiable.user.username
  end

  def timestamp
    notifiable.created_at
  end

  def mark_as_read
    self.destroy
  end
end