class Notification < ActiveRecord::Base

  belongs_to :user, counter_cache: true
  belongs_to :notifiable, polymorphic: true

  validates :user, presence: true

  scope :read,        -> { where.not(read_at: nil).recent.for_render }
  scope :unread,      -> { where(read_at: nil).recent.for_render }
  scope :not_emailed, -> { where(emailed_at: nil) }
  scope :recent,      -> { order(id: :desc) }
  scope :for_render,  -> { includes(:notifiable) }

  delegate :notifiable_title, :notifiable_available?, :check_availability,
           :linkable_resource, to: :notifiable, allow_nil: true

  def mark_as_read
    update(read_at: Time.current)
  end

  def mark_as_unread
    update(read_at: nil)
  end

  def read?
    read_at.present?
  end

  def unread?
    read_at.nil?
  end

  def timestamp
    notifiable.created_at
  end

  def self.add(user, notifiable)
    notification = Notification.existent(user, notifiable)
    if notification.present?
      increment_counter(:counter, notification.id)
    else
      create!(user: user, notifiable: notifiable)
    end
  end

  def self.existent(user, notifiable)
    unread.where(user: user, notifiable: notifiable).first
  end

  def notifiable_action
    case notifiable_type
    when "ProposalNotification"
      "proposal_notification"
    when "Comment"
      "replies_to"
    when "AdminNotification"
      nil
    else
      "comments_on"
    end
  end

  def link
    if notifiable.is_a?(AdminNotification) && notifiable.link.blank?
      nil
    else
      self
    end
  end

  def self.send_pending
    run_at = first_batch_run_at
    User.email_digest.find_in_batches(batch_size: batch_size) do |users|
      users.each do |user|
        email_digest = EmailDigest.new(user)
        email_digest.deliver(run_at)
      end
      run_at += batch_interval
    end
  end

  private

  def self.batch_size
    10000
  end

  def self.batch_interval
    20.minutes
  end

  def self.first_batch_run_at
    Time.current
  end

end
