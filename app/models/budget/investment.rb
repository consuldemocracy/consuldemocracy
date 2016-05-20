class Budget
  class Investment < ActiveRecord::Base

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
    has_many :comments, as: :commentable

    validates :title, presence: true
    validates :author, presence: true
    validates :description, presence: true
    validates_presence_of :unfeasibility_explanation, if: :unfeasibility_explanation_required?

    validates :title, length: { in: 4..Investment.title_max_length }
    validates :description, length: { maximum: Investment.description_max_length }
    validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

    scope :sort_by_confidence_score, -> { reorder(confidence_score: :desc, id: :desc) }
    scope :sort_by_price,            -> { reorder(price: :desc, confidence_score: :desc, id: :desc) }
    scope :sort_by_random,           -> { reorder("RANDOM()") }

    scope :valuation_open,         -> { where(valuation_finished: false) }
    scope :without_admin,          -> { valuation_open.where(administrator_id: nil) }
    scope :managed,                -> { valuation_open.where(valuation_assignments_count: 0).where("administrator_id IS NOT ?", nil) }
    scope :valuating,              -> { valuation_open.where("valuation_assignments_count > 0 AND valuation_finished = ?", false) }
    scope :valuation_finished,     -> { where(valuation_finished: true) }
    scope :feasible,               -> { where(feasible: true) }
    scope :unfeasible,             -> { valuation_finished.where(feasible: false) }
    scope :not_unfeasible,         -> { where("feasible IS ? OR feasible = ?", nil, true) }
    scope :with_supports,          -> { where('cached_votes_up > 0') }

    scope :by_budget,   -> (budget_id)   { where(budget_id: budget_id) }
    scope :by_admin,    -> (admin_id)    { where(administrator_id: admin_id) }
    scope :by_tag,      -> (tag_name)    { tagged_with(tag_name) }
    scope :by_valuator, -> (valuator_id) { where("valuation_assignments.valuator_id = ?", valuator_id).joins(:valuation_assignments) }

    scope :for_render,             -> { includes(:geozone) }

    scope :with_geozone,           -> { where.not(geozone_id: nil) }
    scope :no_geozone,             -> { where(geozone_id: nil) }

    before_save :calculate_confidence_score
    before_validation :set_responsible_name

    def self.filter_params(params)
      params.select{|x,_| %w{geozone_id administrator_id tag_name valuator_id}.include? x.to_s }
    end

    def self.scoped_filter(params, current_filter)
      results = self.by_budget(params[:budget_id])
      if params[:max_for_no_geozone].present? || params[:max_per_geozone].present?
        results = limit_results(results, params[:max_per_geozone].to_i, params[:max_for_no_geozone].to_i)
      end
      results = results.by_geozone(params[:geozone_id])             if params[:geozone_id].present?
      results = results.by_admin(params[:administrator_id])         if params[:administrator_id].present?
      results = results.by_tag(params[:tag_name])                   if params[:tag_name].present?
      results = results.by_valuator(params[:valuator_id])           if params[:valuator_id].present?
      results = results.send(current_filter)                        if current_filter.present?
      results.includes(:geozone, administrator: :user, valuators: :user)
    end

    def self.limit_results(results, max_per_geozone, max_for_no_geozone)
      return results if max_per_geozone <= 0 && max_for_no_geozone <= 0

      ids = []
      if max_per_geozone > 0
        Geozone.pluck(:id).each do |gid|
          ids += Investment.where(geozone_id: gid).order(confidence_score: :desc).limit(max_per_geozone).pluck(:id)
        end
      end

      if max_for_no_geozone > 0
        ids += Investment.no_geozone.order(confidence_score: :desc).limit(max_for_no_geozone).pluck(:id)
      end

      conditions = ["investments.id IN (?)"]
      values = [ids]

      if max_per_geozone == 0
        conditions << "investments.geozone_id IS NOT ?"
        values << nil
      elsif max_for_no_geozone == 0
        conditions << "investments.geozone_id IS ?"
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
      where(geozone_id: geozone == 'all' ? nil : geozone.presence)
    end

    def undecided?
      feasibility == "undecided"
    end

    def feasible?
      feasibility == "feasible"
    end

    def unfeasible?
      feasibility == "unfeasible"
    end

    def unfeasibility_explanation_required?
      unfeasible? && valuation_finished?
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

    def code
      "B#{budget_id}I#{id}"
    end

    def reason_for_not_being_selectable_by(user)
      return permission_problem(user) if permission_problem?(user)

      return :not_voting_allowed unless budget.selecting?
    end

    def reason_for_not_being_ballotable_by(user, ballot)
      return permission_problem(user)    if permission_problem?(user)
      return :no_ballots_allowed         unless budget.balloting?
      return :different_geozone_assigned unless geozone_id.blank? || ballot.blank? || geozone_id == ballot.geozone_id || ballot.geozone_id.nil?
      return :not_enough_money           unless enough_money?(ballot)
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

    def selectable_by?(user)
      reason_for_not_being_selectable_by(user).blank?
    end

    def ballotable_by?(user)
      reason_for_not_being_ballotable_by(user).blank?
    end

    def enough_money?(ballot)
      return true if ballot.blank?
      available_money = ballot.amount_available(geozone)
      price.to_i <= available_money
    end

    def register_selection(user)
      vote_by(voter: user, vote: 'yes') if selectable_by?(user)
    end

    def calculate_confidence_score
      self.confidence_score = ScoreCalculator.confidence_score(total_votes, total_votes)
    end

    def set_responsible_name
      self.responsible_name = author.try(:document_number) if author.try(:document_number).present?
    end

  end
end
