require_dependency Rails.root.join('app', 'models', 'budget', 'investment').to_s
require 'csv'

class Budget
  class Investment < ActiveRecord::Base

    include Flaggable #GET-62 Moderable

    mount_uploader :attachment, AttachmentUploader

    validates :attachment, file_size: { less_than: 5.megabytes }

    scope :with_attachment_verified, -> { where.not(attachment: nil).where(attachment_verified: true).where(hidden_at: nil) }
    scope :with_pending_attachment_verification, -> { where.not(attachment: nil).where(attachment_verified: nil).where(hidden_at: nil) }
    scope :with_attachment_rejected, -> { where.not(attachment: nil).where(attachment_verified: false).where(hidden_at: nil) }
    scope :sort_by_created_at, -> { order('created_at asc') }
    scope :sort_by_created_at_desc, -> { order('created_at desc') }
    scope :pending_flag_review, -> { where(ignored_flag_at: nil, hidden_at: nil) }
    scope :with_ignored_flag, -> { where.not(ignored_flag_at: nil).where(hidden_at: nil) }


    scope :winners, -> { where(winner: true).where(hidden_at: nil) }

    #GET-98
    scope :not_unified, -> { where(unified_with_id: nil) }

    #GET-135
    scope :unified, -> { where.not(unified_with_id: nil) }

    #GET-112
    scope :sort_by_ballots,  -> { joins("LEFT JOIN budget_ballot_lines ON budget_ballot_lines.investment_id = budget_investments.id").reorder( 'sum(budget_ballot_lines.points) desc' ).group('budget_investments.id') }
    scope :sort_by_confirmed_ballots,  -> {     joins("LEFT JOIN budget_ballot_lines ON budget_ballot_lines.investment_id = budget_investments.id")
                                                .joins("LEFT JOIN budget_ballot_confirmations ON budget_ballot_lines.ballot_id = budget_ballot_confirmations.ballot_id")
                                                .where('budget_ballot_confirmations.confirmed_at is not null')
                                                .where('budget_ballot_confirmations.discarted_at is null')
                                                .reorder( 'sum(budget_ballot_lines.points) desc, count(budget_ballot_lines.id) desc' ).group('budget_investments.id') }
    scope :sort_by_title,  -> { reorder( :title ) }


    belongs_to :unified_with, class_name: 'Budget::Investment', foreign_key: :unified_with_id
    has_many :investments_unified_to_me, class_name: 'Budget::Investment', foreign_key: :unified_with_id

    #GET-112
    has_many :budget_ballot_lines, :class_name => 'Budget::Ballot::Line'

    has_many :attachments, as: :attachable
    accepts_nested_attributes_for :attachments,  :reject_if => :all_blank, :allow_destroy => true

    attr_accessor :mark_as_finished_own_valuation, :no_attachment_versions


    def has_project?
      attachments.any? || project_phase.present? || project_content.present?
    end

    #GET-98
    def has_unifications?
      investments_unified_to_me.any?
    end

    #GET-112
    def ballot_lines_sum
      budget_ballot_lines.sum(:points)
    end

    def confirmed_budget_ballot_lines_sum
      confirmed_budget_ballot_lines.sum(:points)
    end

    def confirmed_budget_ballot_lines

      ids = [investments_unified_to_me.pluck(:id), id].flatten
      Budget::Ballot::Line.where(investment_id:  ids)
          .joins("right join budget_ballot_confirmations ON budget_ballot_lines.ballot_id = budget_ballot_confirmations.ballot_id")
          .joins("left join users ON budget_ballot_confirmations.user_id = users.id")
          .where('budget_ballot_confirmations.confirmed_at is not null')
          .where('budget_ballot_confirmations.discarted_at is null')
          .uniq('budget_ballot_confirmations.id')
    end

    def ballot_lines_ratio
      confirmed_budget_ballot_lines.count > 0 ? (1.0 * confirmed_budget_ballot_lines_sum) / confirmed_budget_ballot_lines.count : 0
    end

    def is_unified?
      !unified_with_id.blank?
    end

    def name_and_group
      "#{id} - #{title} || #{group.name} - #{heading.name}"
    end

    def should_show_aside?
      return false # GET-110
      (budget.selecting?  && !unfeasible?) ||
          (budget.balloting?  && feasible?)    ||
          (budget.valuating? && feasible?)
    end

    def should_show_votes?
      return false # GET-110
      budget.selecting?
    end

    def should_show_vote_count?
      return false # GET-110
      budget.valuating?
    end

    def should_show_ballots?
      return false # GET-110
      budget.balloting?
    end


    def update_own_validation_for_valuator(valuator_id)
      return if valuator_id.nil?

      valuation = valuator_assignments.find_by_valuator_id(valuator_id)
      if valuation
        if mark_as_finished_own_valuation? && valuation.finished_by_user_at.nil?

          # Mark with time
          valuation.update(finished_by_user_at: Time.now)
        elsif !mark_as_finished_own_valuation? && valuation.finished_by_user_at

          # Unmark
          valuation.update(finished_by_user_at: nil)
        end
      end
    end

    def is_mark_as_finished_own_valuation_for_valuator?(valuator_id)
      return false if valuator_id.nil?
      !valuator_assignments.find_by_valuator_id(valuator_id).try(:finished_by_user_at).blank?
    end

    def is_mark_as_finished_for_every_valuator?()
      valuator_assignments.pluck(:finished_by_user_at).all?
    end

    def is_mark_as_finished_for_valuator?(valuator_id)
      valuator_assignments.find_by_valuator_id(valuator_id).try(:finished_by_user_at)
    end

    def is_mark_as_finished_for_any_valuator?()
      valuator_assignments.pluck(:finished_by_user_at).any?
    end

    def valuator_assignments_count
      valuator_assignments.count
    end

    def valuator_assignments_ordered_by_completion_date
      valuator_assignments.order("finished_by_user_at DESC")
    end
    def valuator_assignments_finished_count
      valuator_assignments.where.not(finished_by_user_at: nil).count
    end

    def mark_as_finished_own_valuation?
      "1".eql?(mark_as_finished_own_valuation)
    end

    def image_attached?
      !"application/pdf".eql?(attachment.try(:content_type))
    end

    def likes
      cached_votes_up
    end

    def dislikes
      votes_for.where(vote_flag: false).count
    end

    def total_votes
      votes_for.count
    end

    def votable_by?(user)
      return false unless user
      user.level_three_verified?
      #!user.voted_for?(self) #REV
    end

    def register_selection(user, vote_value)
      vote_by(voter: user, vote: vote_value) if selectable_by?(user)
    end

    def reason_for_not_being_selectable_by(user)
      return permission_problem(user) if permission_problem?(user)
      return :different_heading_assigned unless valid_heading?(user)

      return :no_selecting_allowed unless budget.accepting?
    end

    def verify_attachment!(user)
      update!(attachment_verified: true, attachment_verified_by: user.username)
    end

    def reject_attachment!(user)
      update!(attachment_verified: false, attachment_verified_by: user.username)
    end

    def has_attachment?
      !attachment.blank?
    end

    def attachment_verified?
      attachment_verified == true
    end

    def attachment_rejected?
      attachment_verified == false
    end

    def attachment_pending?
      attachment_verified.nil?
    end

    def group_name
      group.name
    end

    def author_name
    author.name
    end

    def author_email
      author.email
    end

    def author_phone
      author.phone_number
    end

    def self.to_csv
      attributes = %w{id title created_at group_name author_name author_email author_phone}

      CSV.generate(headers: true) do |csv|
        csv << attributes.map { |attr| Budget::Investment.human_attribute_name attr }

        all.each do |user|
          csv << attributes.map{ |attr| user.send(attr) }
        end
      end
    end
  end
end
