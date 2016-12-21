class Poll < ActiveRecord::Base
  has_many :booth_assignments, class_name: "Poll::BoothAssignment"
  has_many :booths, through: :booth_assignments
  has_many :voters, through: :booth_assignments
  has_many :officer_assignments, through: :booth_assignments
  has_many :officers, through: :officer_assignments
  has_many :questions

  validates :name, presence: true

  validate :date_range

  scope :current,  -> { where('starts_at <= ? and ? <= ends_at', Time.now, Time.now) }
  scope :incoming, -> { where('? < starts_at', Time.now) }
  scope :expired,  -> { where('ends_at < ?', Time.now) }

  scope :sort_for_list, -> { order(:starts_at) }

  def current?(timestamp = DateTime.now)
    starts_at <= timestamp && timestamp <= ends_at
  end

  def incoming?(timestamp = DateTime.now)
    timestamp < starts_at
  end

  def expired?(timestamp = DateTime.now)
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
      errors.add(:starts_at, I18n.t('activerecord.errors.invalid_date_range'))
    end
  end

end
