class Poll < ActiveRecord::Base
  has_many :booth_assignments, class_name: "Poll::BoothAssignment"
  has_many :booths, through: :booth_assignments
  has_many :partial_results, through: :booth_assignments
  has_many :white_results, through: :booth_assignments
  has_many :null_results, through: :booth_assignments
  has_many :voters
  has_many :officer_assignments, through: :booth_assignments
  has_many :officers, through: :officer_assignments
  has_many :questions

  has_and_belongs_to_many :geozones

  validates :name, presence: true

  validate :date_range

  scope :current,  -> { where('starts_at <= ? and ? <= ends_at', Time.current, Time.current) }
  scope :incoming, -> { where('? < starts_at', Time.current) }
  scope :expired,  -> { where('ends_at < ?', Time.current) }
  scope :published, -> { where('published = ?', true) }
  scope :by_geozone_id, ->(geozone_id) { where(geozones: {id: geozone_id}.joins(:geozones)) }

  scope :sort_for_list, -> { order(:geozone_restricted, :starts_at, :name) }

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
    user.present? &&
      user.level_two_or_three_verified? &&
      current? &&
      (!geozone_restricted || geozone_ids.include?(user.geozone_id))
  end

  def self.answerable_by(user)
    return none if user.nil? || user.unverified?
    current.joins('LEFT JOIN "geozones_polls" ON "geozones_polls"."poll_id" = "polls"."id"')
           .where('geozone_restricted = ? OR geozones_polls.geozone_id = ?', false, user.geozone_id)
  end

  def votable_by?(user)
    !document_has_voted?(user.document_number, user.document_type)
  end

  def document_has_voted?(document_number, document_type)
    voters.where(document_number: document_number, document_type: document_type).exists?
  end

  def date_range
    unless starts_at.present? && ends_at.present? && starts_at <= ends_at
      errors.add(:starts_at, I18n.t('errors.messages.invalid_date_range'))
    end
  end

end
