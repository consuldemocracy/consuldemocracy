class Notification < ActiveRecord::Base
  belongs_to :user, counter_cache: true
  belongs_to :notifiable, polymorphic: true

  scope :unread,      -> { all }
  scope :recent,      -> { order(id: :desc) }
  scope :not_emailed, -> { where(emailed_at: nil) }
  scope :for_render,  -> { includes(:notifiable) }


  def timestamp
    notifiable.created_at
  end

  def mark_as_read
    self.destroy
  end

  def self.add(user_id, notifiable)
    notification = Notification.find_by(user_id: user_id, notifiable: notifiable)

    if notification.present?
      Notification.increment_counter(:counter, notification.id)
    else
      Notification.create!(user_id: user_id, notifiable: notifiable)
    end
  end

  def notifiable_title
    case notifiable.class.name
    when "ProposalNotification"
      notifiable.proposal.title
    when "Comment"
      notifiable.commentable.title
    else
      notifiable.title
    end
  end

  def notifiable_action
    case notifiable_type
    when "ProposalNotification"
      "proposal_notification"
    when "Comment"
      "replies_to"
    else
      "comments_on"
    end
  end

  def linkable_resource
    notifiable.is_a?(ProposalNotification) ? notifiable.proposal : notifiable
  end

end
