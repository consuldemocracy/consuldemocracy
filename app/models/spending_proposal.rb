class SpendingProposal < ActiveRecord::Base
  include Measurable
  include Sanitizable
  include Taggable
  include Searchable

  acts_as_votable

  belongs_to :author, -> { with_hidden }, class_name: "User", foreign_key: "author_id"
  belongs_to :geozone
  belongs_to :administrator
  has_many :valuation_assignments, dependent: :destroy
  has_many :valuators, through: :valuation_assignments

  validates :title, presence: true
  validates :author, presence: true
  validates :description, presence: true
  validates :feasible_explanation, presence: { if: :feasible_explanation_required? }

  validates :title, length: { in: 4..SpendingProposal.title_max_length }
  validates :description, length: { maximum: SpendingProposal.description_max_length }
  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  scope :valuation_open,         -> { where(valuation_finished: false) }
  scope :without_admin,          -> { valuation_open.where(administrator_id: nil) }
  scope :managed,                -> { valuation_open.where(valuation_assignments_count: 0).where("administrator_id IS NOT ?", nil) }
  scope :valuating,              -> { valuation_open.where("valuation_assignments_count > 0 AND valuation_finished = ?", false) }
  scope :valuation_finished,     -> { where(valuation_finished: true) }
  scope :feasible,               -> { where(feasible: true) }
  scope :unfeasible,             -> { where(feasible: false) }
  scope :not_unfeasible,         -> { where("feasible IS ? OR feasible = ?", nil, true) }
  scope :with_supports,          -> { where("cached_votes_up > 0") }

  scope :by_admin,    ->(admin)    { where(administrator_id: admin.presence) }
  scope :by_tag,      ->(tag_name) { tagged_with(tag_name) }
  scope :by_valuator, ->(valuator) { where("valuation_assignments.valuator_id = ?", valuator.presence).joins(:valuation_assignments) }

  scope :for_render, -> { includes(:geozone) }

  before_validation :set_responsible_name

  def description
    super.try :html_safe
  end

  def self.scoped_filter(params, current_filter)
    results = self
    results = results.by_geozone(params[:geozone_id])             if params[:geozone_id].present?
    results = results.by_admin(params[:administrator_id])         if params[:administrator_id].present?
    results = results.by_tag(params[:tag_name])                   if params[:tag_name].present?
    results = results.by_valuator(params[:valuator_id])           if params[:valuator_id].present?
    results = results.send(current_filter)                        if current_filter.present?
    results.includes(:geozone, administrator: :user, valuators: :user)
  end

  def searchable_values
    { title              => "A",
      author.username    => "B",
      geozone.try(:name) => "B",
      description        => "C"
    }
  end

  def self.search(terms)
    pg_search(terms)
  end

  def self.by_geozone(geozone)
    if geozone == "all"
      where(geozone_id: nil)
    else
      where(geozone_id: geozone.presence)
    end
  end

  def feasibility
    case feasible
    when true
      "feasible"
    when false
      "not_feasible"
    else
      "undefined"
    end
  end

  def unfeasible_email_pending?
    unfeasible_email_sent_at.blank? && unfeasible? && valuation_finished?
  end

  def unfeasible?
    feasible == false
  end

  def valuation_finished?
    valuation_finished
  end

  def feasible_explanation_required?
    valuation_finished? && unfeasible?
  end

  def total_votes
    cached_votes_up + physical_votes
  end

  def code
    "#{created_at.strftime("%Y")}-#{id}" + (administrator.present? ? "-A#{administrator.id}" : "")
  end

  def send_unfeasible_email
    Mailer.unfeasible_spending_proposal(self).deliver_later
    update(unfeasible_email_sent_at: Time.current)
  end

  def reason_for_not_being_votable_by(user)
    return :not_voting_allowed if Setting["feature.spending_proposal_features.voting_allowed"].blank?
    return :not_logged_in unless user
    return :not_verified  unless user.can?(:vote, SpendingProposal)
    return :unfeasible    if unfeasible?
    return :organization  if user.organization?
  end

  def votable_by?(user)
    reason_for_not_being_votable_by(user).blank?
  end

  def register_vote(user, vote_value)
    if votable_by?(user)
      vote_by(voter: user, vote: vote_value)
    end
  end

  def set_responsible_name
    self.responsible_name = author.try(:document_number) if author.try(:document_number).present?
  end

  def self.finished_and_feasible
    valuation_finished.feasible
  end

  def self.finished_and_unfeasible
    valuation_finished.unfeasible
  end

end
