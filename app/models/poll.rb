class Poll < ActiveRecord::Base

  AGE_STEPS = [16,20,25,30,35,40,45,50,55,60,65]

  include Imageable

  has_many :booth_assignments, class_name: "Poll::BoothAssignment"
  has_many :booths, through: :booth_assignments
  has_many :partial_results, through: :booth_assignments
  has_many :recounts, through: :booth_assignments
  has_many :voters
  has_many :officer_assignments, through: :booth_assignments
  has_many :officers, through: :officer_assignments
  has_many :questions

  has_and_belongs_to_many :geozones

  accepts_nested_attributes_for :questions

  validates :name, presence: true

  validate :date_range

  scope :current,  -> { where('starts_at <= ? and ? <= ends_at', Date.current.beginning_of_day, Date.current.beginning_of_day) }
  scope :incoming, -> { where('? < starts_at', Date.current.beginning_of_day) }
  scope :expired,  -> { where('ends_at < ?', Date.current.beginning_of_day) }
  scope :published, -> { where('published = ?', true) }
  scope :by_geozone_id, ->(geozone_id) { where(geozones: {id: geozone_id}.joins(:geozones)) }
  scope :with_nvotes, -> { where.not(nvotes_poll_id: nil) }

  scope :sort_for_list, -> { order(:geozone_restricted, :starts_at, :name) }

  def current?(timestamp = Date.current.beginning_of_day)
    starts_at <= timestamp && timestamp <= ends_at
  end

  def incoming?(timestamp = Date.current.beginning_of_day)
    timestamp < starts_at
  end

  def expired?(timestamp = Date.current.beginning_of_day)
    ends_at < timestamp
  end

  def self.current_or_incoming
    current + incoming
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

  def self.votable_by(user)
    answerable_by(user).
    not_voted_by(user)
  end

  def votable_by?(user)
    answerable_by?(user) &&
    not_voted_by?(user)
  end

  def self.not_voted_by(user)
    where("polls.id not in (?)", poll_ids_voted_by(user))
  end

  def self.poll_ids_voted_by(user)
    return -1 if Poll::Voter.where(user: user).empty?

    Poll::Voter.where(user: user).pluck(:poll_id)
  end

  def not_voted_by?(user)
    Poll::Voter.where(poll: self, user: user).empty?
  end

  def voted_by?(user)
    Poll::Voter.where(poll: self, user: user).exists?
  end

  def voted_in_booth?(user)
    Poll::Voter.where(poll: self, user: user, origin: "booth").exists?
  end

  def voted_in_booth?(user)
    Poll::Voter.where(poll: self, user: user, origin: "booth").exists?
  end

  def date_range
    unless starts_at.present? && ends_at.present? && starts_at <= ends_at
      errors.add(:starts_at, I18n.t('errors.messages.invalid_date_range'))
    end
  end

  def self.server_shared_key
    Rails.application.secrets["nvotes_shared_key"] || ENV["nvotes_shared_key"]
  end

  def self.server_url
    Rails.application.secrets["nvotes_server_url"] || ENV["nvotes_server_url"]
  end

end
