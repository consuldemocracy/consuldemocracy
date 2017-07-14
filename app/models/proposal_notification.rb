class ProposalNotification < ActiveRecord::Base

  include Graphqlable

  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :proposal

  validates :title, presence: true
  validates :body, presence: true
  validates :proposal, presence: true
  validate :minimum_interval

  scope :public_for_api, -> { where(proposal_id: Proposal.public_for_api.pluck(:id)) }

  def minimum_interval
    return true if proposal.try(:notifications).blank?
    interval = Setting[:proposal_notification_minimum_interval_in_days]
    minimum_interval = (Time.current - interval.to_i.days).to_datetime
    if proposal.notifications.last.created_at > minimum_interval
      errors.add(:title, I18n.t('activerecord.errors.models.proposal_notification.attributes.minimum_interval.invalid', interval: interval))
    end
  end

end
