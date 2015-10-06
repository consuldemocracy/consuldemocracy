class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :activity

  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(id: :desc) }
  scope :for_render, -> { includes(activity: [:user, :trackable]) }

  def timestamp
    activity.trackable.created_at
  end
end
