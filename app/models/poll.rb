class Poll < ActiveRecord::Base
  has_many :booth_assignments, class_name: "Poll::BoothAssignment"
  has_many :booths, through: :booth_assignments
  has_many :voters, through: :booth_assignments
  has_many :officer_assignments, through: :booth_assignments
  has_many :officers, through: :officer_assignments
  has_many :questions

  validates :name, presence: true

  validate :date_range

  scope :current,  -> { where('starts_at <= ? and ? <= ends_at', Time.current, Time.current) }
  scope :incoming, -> { where('? < starts_at', Time.current) }
  scope :expired,  -> { where('ends_at < ?', Time.current) }
  scope :published,  -> { where('published = ?', true) }

  scope :sort_for_list, -> { order(:starts_at) }

  def current?(timestamp = DateTime.current)
    starts_at <= timestamp && timestamp <= ends_at
  end

  def incoming?(timestamp = DateTime.current)
    timestamp < starts_at
  end

  def expired?(timestamp = DateTime.current)
    ends_at < timestamp
  end

  def answerable_by?(user)
    user.present? && user.level_two_or_three_verified? && current?
  end

  def self.answerable_by(user)
    return none if user.nil? || user.unverified?
    current
  end

  def document_has_voted?(document_number, document_type)
    voters.where(document_number: document_number, document_type: document_type).exists?
  end

  def date_range
    unless starts_at.present? && ends_at.present? && starts_at <= ends_at
      errors.add(:starts_at, I18n.t('errors.messages.invalid_date_range'))
    end
  end

  def scoped_agora_poll_id(user)
    128 #agora_election_id
  end

  def server_shared_key
    Rails.application.secrets["nvotes_shared_key"]
  end

  def server_url
    Rails.application.secrets["nvotes_server_url"]
  end

end
