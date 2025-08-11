class Poll < ApplicationRecord
  include Imageable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases
  include Notifiable
  include Searchable
  include Sluggable
  include Reportable
  include SDG::Relatable

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
  has_many :questions, inverse_of: :poll, dependent: :destroy
  has_many :comments, as: :commentable, inverse_of: :commentable
  has_many :ballot_sheets

  has_many :geozones_polls
  has_many :geozones, through: :geozones_polls
  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :polls
  belongs_to :related, polymorphic: true
  belongs_to :budget

  validates_translation :name, presence: true

  validates :starts_at, presence: true
  validates :ends_at, presence: true

  validates :starts_at,
            comparison: {
              less_than_or_equal_to: :ends_at,
              message: ->(*) { I18n.t("errors.messages.invalid_date_range") }
            },
            allow_blank: true,
            if: -> { ends_at }
  validates :starts_at,
            comparison: {
              greater_than_or_equal_to: ->(*) { Time.current },
              message: ->(*) { I18n.t("errors.messages.past_date") }
            },
            allow_blank: true,
            on: :create
  validates :ends_at,
            comparison: {
              greater_than_or_equal_to: ->(*) { Time.current },
              message: ->(*) { I18n.t("errors.messages.past_date") }
            },
            on: :update,
            if: -> { will_save_change_to_ends_at? }

  validate :start_date_change, on: :update
  validate :end_date_change, on: :update
  validate :only_one_active, unless: :public?

  accepts_nested_attributes_for :questions, reject_if: :all_blank, allow_destroy: true

  scope :for, ->(element) { where(related: element) }
  scope :current, -> { where(starts_at: ..Time.current, ends_at: Time.current..) }
  scope :expired, -> { where(ends_at: ...Time.current) }
  scope :recounting, -> { where(ends_at: (RECOUNT_DURATION.ago)...Time.current) }
  scope :published, -> { where(published: true) }
  scope :by_geozone_id, ->(geozone_id) { where(geozones: { id: geozone_id }.joins(:geozones)) }
  scope :public_for_api, -> { all }
  scope :not_budget, -> { where(budget_id: nil) }
  scope :created_by_admin, -> { where(related_type: nil) }

  def self.sort_for_list(user = nil)
    all.sort do |poll, another_poll|
      compare_polls(poll, another_poll, user)
    end
  end

  def self.compare_polls(poll, another_poll, user)
    weight_comparison = poll.weight(user) <=> another_poll.weight(user)
    return weight_comparison unless weight_comparison.zero?

    time_comparison = compare_times(poll, another_poll)
    return time_comparison unless time_comparison.zero?

    poll.name <=> another_poll.name
  end

  def self.compare_times(poll, another_poll)
    if poll.expired? && another_poll.expired?
      another_poll.ends_at <=> poll.ends_at
    else
      poll.starts_at <=> another_poll.starts_at
    end
  end

  def self.overlaping_with(poll)
    where("? < ends_at and ? >= starts_at",
          poll.starts_at.beginning_of_day,
          poll.ends_at.end_of_day)
      .excluding(poll)
      .where(related: poll.related)
  end

  def title
    name
  end

  def started?(timestamp = Time.current)
    starts_at.present? && starts_at < timestamp
  end

  def current?(timestamp = Time.current)
    timestamp.between?(starts_at, ends_at)
  end

  def expired?(timestamp = Time.current)
    ends_at < timestamp
  end

  def recounts_confirmed?
    ends_at < 1.month.ago
  end

  def self.current_or_recounting
    current.or(recounting)
  end

  def answerable_by?(user)
    user.present? &&
      user.level_two_or_three_verified? &&
      current? &&
      (!geozone_restricted || geozone_ids.include?(user.geozone_id))
  end

  def self.answerable_by(user)
    return none if user.nil? || user.unverified?

    current.left_joins(:geozones)
           .where("geozone_restricted = ? OR geozones.id = ?", false, user.geozone_id)
  end

  def self.votable_by(user)
    answerable_by(user).not_voted_by(user)
  end

  def votable_by?(user)
    return false if user_has_an_online_ballot?(user)

    answerable_by?(user) && not_voted_by?(user)
  end

  def user_has_an_online_ballot?(user)
    budget.present? && budget.ballots.find_by(user: user)&.lines.present?
  end

  def self.not_voted_by(user)
    where.not(id: poll_ids_voted_by(user))
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

  def start_date_change
    if will_save_change_to_starts_at?
      if starts_at_in_database < Time.current
        errors.add(:starts_at, I18n.t("errors.messages.cannot_change_date.poll_started"))
      elsif starts_at < Time.current
        errors.add(:starts_at, I18n.t("errors.messages.past_date"))
      end
    end
  end

  def end_date_change
    if will_save_change_to_ends_at? && ends_at_in_database < Time.current
      errors.add(:ends_at, I18n.t("errors.messages.cannot_change_date.poll_ended"))
    end
  end

  def geozone_restricted_to=(geozones)
    self.geozone_restricted = true
    self.geozones = geozones
  end

  def generate_slug?
    slug.nil?
  end

  def only_one_active
    return if starts_at.blank?
    return if ends_at.blank?
    return if Poll.overlaping_with(self).none?

    errors.add(:starts_at, I18n.t("activerecord.errors.messages.another_poll_active"))
  end

  def public?
    related.nil?
  end

  def answer_count
    Poll::Answer.where(question: questions).count
  end

  def budget_poll?
    budget.present?
  end

  def searchable_translations_definitions
    {
      name => "A",
      summary => "C",
      description => "D"
    }
  end

  def searchable_values
    searchable_globalized_values
  end

  def self.search(terms)
    pg_search(terms)
  end

  def weight(user)
    if geozone_restricted?
      if answerable_by?(user)
        50
      else
        100
      end
    else
      0
    end
  end
end
