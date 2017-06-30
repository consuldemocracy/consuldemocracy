class SpendingProposal < ActiveRecord::Base
  include Measurable
  include Sanitizable
  include Taggable
  include Searchable

  acts_as_votable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  belongs_to :geozone
  belongs_to :administrator
  has_many :valuation_assignments, dependent: :destroy
  has_many :valuators, through: :valuation_assignments
  has_many :ballot_lines, dependent: :destroy
  has_many :comments, as: :commentable

  validates :title, presence: true
  validates :author, presence: true
  validates :description, presence: true
  validates :feasible_explanation, presence: { if: :feasible_explanation_required? }

  validates :title, length: { in: 4..SpendingProposal.title_max_length }
  validates :description, length: { maximum: 10000 }
  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  scope :sort_by_confidence_score, -> (default=nil) { reorder(confidence_score: :desc, id: :desc) }
  scope :sort_by_price,            -> (default=nil) { reorder(price: :desc, confidence_score: :desc, id: :desc) }
  scope :sort_by_random,           -> (seed)    { reorder("RANDOM()") }

  scope :valuation_open,         -> { where(valuation_finished: false) }
  scope :without_admin,          -> { valuation_open.where(administrator_id: nil) }
  scope :managed,                -> { valuation_open.where(valuation_assignments_count: 0).where("administrator_id IS NOT ?", nil) }
  scope :valuating,              -> { valuation_open.where("valuation_assignments_count > 0 AND valuation_finished = ?", false) }
  scope :valuation_finished,     -> { where(valuation_finished: true) }
  scope :feasible,               -> { where(feasible: true) }
  scope :unfeasible,             -> { valuation_finished.where(feasible: false) }
  scope :compatible,             -> { where(compatible: true) }
  scope :incompatible,           -> { where(compatible: false) }
  scope :not_unfeasible,         -> { where("feasible IS ? OR feasible = ?", nil, true) }
  scope :with_supports,          -> { where('cached_votes_up > 0') }
  scope :by_forum,               -> { where(forum: true) }
  scope :by_admin,    ->(admin)     { where(administrator_id: admin.presence) }
  scope :by_tag,      ->(tag_name)  { tagged_with(tag_name) }
  scope :by_valuator, ->(valuator)  { where("valuation_assignments.valuator_id = ?", valuator.presence).joins(:valuation_assignments) }

  scope :for_render, -> { includes(:geozone) }

  scope :district_wide,          -> { where.not(geozone_id: nil) }
  scope :city_wide,              -> { where(geozone_id: nil) }

  before_save :calculate_confidence_score
  before_validation :set_responsible_name

  def description
    super.try :html_safe
  end

  def self.filter_params(params)
    params.select{|x, _| %w{geozone_id administrator_id tag_name valuator_id}.include? x.to_s }
  end

  def self.scoped_filter(params, current_filter)
    results = self
    results = limit_results(results, params)                      if params[:max_for_no_geozone].present? || params[:max_per_geozone].present?
    results = results.by_geozone(params[:geozone_id])             if params[:geozone_id].present?
    results = results.by_admin(params[:administrator_id])         if params[:administrator_id].present?
    results = results.by_tag(params[:tag_name])                   if params[:tag_name].present?
    results = results.by_valuator(params[:valuator_id])           if params[:valuator_id].present?
    results = results.send(current_filter)                        if current_filter.present?
    results.includes(:geozone, administrator: :user, valuators: :user)
  end

  def self.limit_results(results, params)
    max_per_geozone = params[:max_per_geozone].to_i
    max_for_no_geozone = params[:max_for_no_geozone].to_i

    return results if max_per_geozone <= 0 && max_for_no_geozone <= 0

    ids = []
    if max_per_geozone > 0
      Geozone.pluck(:id).each do |gid|
        ids += SpendingProposal.select(:id).where(geozone_id: gid).order(confidence_score: :desc).limit(max_per_geozone).map(&:id)
      end
    end

    if max_for_no_geozone > 0
      ids += SpendingProposal.select(:id).city_wide.order(confidence_score: :desc).limit(max_for_no_geozone).map(&:id)
    end

    conditions = ["spending_proposals.id IN (?)"]
    values = [ids]

    if params[:max_per_geozone].blank?
      conditions << "spending_proposals.geozone_id IS NOT ?"
      values << nil
    elsif params[:max_for_no_geozone].blank?
      conditions << "spending_proposals.geozone_id IS ?"
      values << nil
    end

    results.where(conditions.join(' OR '), *values)
  end

  def searchable_values
    { title              => 'A',
      author.username    => 'B',
      geozone.try(:name) => 'B',
      description        => 'C'
    }
  end

  def self.search(terms)
    self.pg_search(terms)
  end

  def self.by_geozone(geozone)
    if geozone == 'all'
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
    feasible == false && valuation_finished == true
  end

  def valuation_finished?
    valuation_finished
  end

  def feasible_explanation_required?
    valuation_finished? && unfeasible?
  end

  def total_votes
    cached_votes_up + physical_votes + delegated_votes - forum_votes
  end

  def delegated_votes
    count = 0
    representative_voters.each do |voter|
      count += voter.forum.represented_users.select { |u| !u.voted_for?(self) }.count
    end
    return count
  end

  def representative_voters
    Vote.representative_votes.for_spending_proposals(self).collect(&:voter)
  end

  def forum_votes
    Vote.representative_votes.for_spending_proposals(self).count
  end

  def code
    "#{created_at.strftime('%Y')}-#{id}" + (administrator.present? ? "-A#{administrator.id}" : "")
  end

  def send_unfeasible_email
    Mailer.unfeasible_spending_proposal(self).deliver_later
    update(unfeasible_email_sent_at: Time.current)
  end

  def reason_for_not_being_votable_by(user)
    return permission_problem(user) if permission_problem?(user)
    return :not_voting_allowed unless voting_allowed?

    if city_wide?
      return :no_city_supports_available unless user.city_wide_spending_proposals_supported_count > 0
    else # district_wide

      if user.supported_spending_proposals_geozone_id.present? &&
         geozone_id != user.supported_spending_proposals_geozone_id
        return :different_district_assigned
      end

      return :no_district_supports_available unless user.district_wide_spending_proposals_supported_count > 0
    end
  end

  def reason_for_not_being_ballotable_by(user)
    return permission_problem(user)    if permission_problem?(user)
    return :no_ballots_allowed         unless final_voting_allowed?
    return :different_geozone_assigned unless can_vote_in_geozone?(user)
    return :not_enough_money           unless enough_money?(user.ballot)
  end

  def permission_problem(user)
    return :not_logged_in unless user
    return :organization  if user.organization?
    return :not_verified  unless user.can?(:vote, SpendingProposal)
    return nil
  end

  def permission_problem?(user)
    permission_problem(user).present?
  end

  def votable_by?(user)
    reason_for_not_being_votable_by(user).blank?
  end

  def ballotable_by?(user)
    reason_for_not_being_ballotable_by(user).blank?
  end

  ### Think of a better way to describe the different phases
  def voting_allowed?
    Setting["feature.spending_proposal_features.voting_allowed"].present?
  end

  def final_voting_allowed?
    Setting["feature.spending_proposal_features.final_voting_allowed"].present?
  end
  ###

  def enough_money?(ballot)
    return true if ballot.blank?
    available_money = ballot.amount_available(geozone)
    price.to_i <= available_money
  end

  def can_vote_in_geozone?(user)
    return true if city_wide? || user.ballot.blank?

    (geozone == user.ballot.geozone) || user.ballot.spending_proposals.district_wide.blank?
  end

  def register_vote(user, vote_value)
    if votable_by?(user)
      vote_by(voter: user, vote: vote_value)
      if vote_registered?
        if city_wide?
          count = user.city_wide_spending_proposals_supported_count
          user.update(city_wide_spending_proposals_supported_count: count - 1)
        else
          count = user.district_wide_spending_proposals_supported_count
          user.update(district_wide_spending_proposals_supported_count: count - 1,
                      supported_spending_proposals_geozone_id: self.geozone_id)
        end
      end
    end
  end

  def district_wide?
    geozone.present?
  end

  def city_wide?
    !district_wide?
  end

  def calculate_confidence_score
    self.confidence_score = ScoreCalculator.confidence_score(total_votes, total_votes)
  end

  def set_responsible_name
    self.responsible_name = author.try(:document_number) if author.try(:document_number).present?
  end

  def self.finished_and_feasible
    valuation_finished.feasible
  end

  def self.sort_by_delegated_ballots_and_price(spending_proposals, delegated_ballots)
    arr = spending_proposals.map do |sp|
      { sp: sp,
        ballots: sp.ballot_lines_count + (delegated_ballots[sp.id] || 0),
        price: sp.price }
    end
    arr.sort! do |a,b|
      ballots = b[:ballots] <=> a[:ballots]
      ballots != 0 ? ballots : b[:price] <=> a[:price]
    end
    arr.map{|h| h[:sp]}
  end

end
