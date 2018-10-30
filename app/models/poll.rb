class Poll < ActiveRecord::Base
  include Imageable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases
  include Notifiable

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
  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'

  validates :name, presence: true

  validate :date_range

  scope :current,  -> { where('starts_at <= ? and ? <= ends_at', Date.current.beginning_of_day, Time.zone.now) }
  scope :incoming, -> { where('? < starts_at', Time.zone.now) }
  scope :expired,  -> { where('ends_at < ?', Time.zone.now) }
  scope :recounting, -> { Poll.where(ends_at: (Date.current.beginning_of_day - RECOUNT_DURATION)..Date.current.beginning_of_day) }
  scope :published, -> { where('published = ?', true) }
  scope :by_geozone_id, ->(geozone_id) { where(geozones: {id: geozone_id}.joins(:geozones)) }
  scope :public_for_api, -> { all }
  scope :sort_for_list, -> { order(:geozone_restricted, :starts_at, :name) }

  def title
    name
  end

  def current?(timestamp = Time.zone.now)
    starts_at <= timestamp && timestamp <= ends_at
  end

  def incoming?(timestamp = Time.zone.now)
    timestamp < starts_at
  end

  def expired?(timestamp = Time.zone.now)
    ends_at < timestamp
  end

  def self.current_or_incoming
    current + incoming
  end

  def self.current_or_recounting_or_incoming
    current + recounting + incoming
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

  def voted_in_booth?(user)
    Poll::Voter.where(poll: self, user: user, origin: "booth").exists?
  end

  def voted_in_web?(user)
    Poll::Voter.where(poll: self, user: user, origin: "web").exists?
  end

  def date_range
    unless starts_at.present? && ends_at.present? && starts_at <= ends_at
      errors.add(:starts_at, I18n.t('errors.messages.invalid_date_range'))
    end
  end

  def next_year
    starts_at.year+1
  end

  def show_results?
    results_enabled? && (expired? || (!expired? && when_show_results))
  end

  def show_stats?
    stats_enabled? && (expired? || (!expired? && when_show_stats))
  end

  def name_without_year
    name.gsub(/[0-9]*/,'')
  end

  def self.current_cartell
    Poll.where(kind: 'cartel').last
  end
end

# == Schema Information
#
# Table name: polls
#
#  id                 :integer          not null, primary key
#  name               :string
#  starts_at          :datetime
#  ends_at            :datetime
#  published          :boolean          default(FALSE)
#  geozone_restricted :boolean          default(FALSE)
#  summary            :text
#  description        :text
#  comments_count     :integer          default(0)
#  author_id          :integer
#  hidden_at          :datetime
#  results_enabled    :boolean          default(FALSE)
#  stats_enabled      :boolean          default(FALSE)
#  created_at         :datetime
#  updated_at         :datetime
#
