class Poll < ActiveRecord::Base
  include Imageable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases
  include Notifiable

  translates :name,        touch: true
  translates :summary,     touch: true
  translates :description, touch: true
  include Globalizable

  RECOUNT_DURATION = 1.week

  has_many :booth_assignments, class_name: "Poll::BoothAssignment"
  has_many :booths, through: :booth_assignments
  has_many :partial_results, through: :booth_assignments
  has_many :recounts, through: :booth_assignments
  has_many :voters
  has_many :officer_assignments, through: :booth_assignments
  has_many :officers, through: :officer_assignments
  has_many :questions
  has_many :comments, as: :commentable

  has_and_belongs_to_many :geozones
  belongs_to :author, -> { with_hidden }, class_name: "User", foreign_key: "author_id"

  validates_translation :name, presence: true
  validate :date_range

  scope :current,  -> { where("starts_at <= ? and ? <= ends_at", Date.current.beginning_of_day, Date.current.beginning_of_day) }
  scope :expired,  -> { where("ends_at < ?", Date.current.beginning_of_day) }
  scope :recounting, -> { Poll.where(ends_at: (Date.current.beginning_of_day - RECOUNT_DURATION)..Date.current.beginning_of_day) }
  scope :published, -> { where("published = ?", true) }
  scope :by_geozone_id, ->(geozone_id) { where(geozones: {id: geozone_id}.joins(:geozones)) }
  scope :public_for_api, -> { all }

  scope :sort_for_list, -> { joins(:translations).order(:geozone_restricted, :starts_at, "poll_translations.name") }

  def title
    name
  end

  def current?(timestamp = Date.current.beginning_of_day)
    starts_at <= timestamp && timestamp <= ends_at
  end

  def expired?(timestamp = Date.current.beginning_of_day)
    ends_at < timestamp
  end

  def self.current_or_recounting
    current + recounting
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
           .where("geozone_restricted = ? OR geozones_polls.geozone_id = ?", false, user.geozone_id)
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

  def voted_in_web?(user)
    Poll::Voter.where(poll: self, user: user, origin: "web").exists?
  end

  def date_range
    unless starts_at.present? && ends_at.present? && starts_at <= ends_at
      errors.add(:starts_at, I18n.t("errors.messages.invalid_date_range"))
    end
  end

end
