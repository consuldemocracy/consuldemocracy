class ProposalNotification < ActiveRecord::Base
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :proposal

  validates :title, presence: true
  validates :body, presence: true
  validates :proposal, presence: true
  validate :minimum_interval

  def minimum_interval
    return true if proposal.notifications.blank?
    if proposal.notifications.last.created_at > (Time.now - Setting[:proposal_notification_minimum_interval_in_days].to_i.days).to_datetime
      errors.add(:minimum_interval, I18n.t('activerecord.errors.models.proposal_notification.minimum_interval', interval: Setting[:proposal_notification_minimum_interval]))
    end
  end

end