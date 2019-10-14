class Budget
  class Ballot < ActiveRecord::Base

    MAX_LINES_PER_HEADING = 3 #GET-107

    belongs_to :user
    belongs_to :budget

    has_many :lines, dependent: :destroy
    has_many :investments, through: :lines
    has_many :groups, -> { uniq }, through: :lines
    has_many :headings, -> { uniq }, through: :lines
    has_one :confirmation

    before_validation  :initialize_random_seed

    #GET-135 will calculate points by investment in ballot, checking if is a unified investment
    def points_for_investment(selected_investment)

      unified_investment = is_present_as_unified_in_ballot?(selected_investment)
      if unified_investment
        unified_investment.points
      else
        matched_line = lines.find_by_investment_id(selected_investment.id)
        matched_line.try(:points)
      end
    end

    #GET-135
    def is_present_as_unified_in_ballot?(selected_investment)
      in_unified_investments_ids = budget.investments.unified.where(unified_with_id: selected_investment.id).pluck :id
      lines.where(investment_id: in_unified_investments_ids ).first
    end


    #GET-125
    def summary

      lines_summary = lines.collect { |line| "[#{line.investment.id}] #{line.investment.title} #{line.points}" }
      "user_id: #{user.name}, group_id: #{group.name}, completed: #{completed?}, lines: #{lines_summary}"
    end

    def partially_completed?
      lines.any?
    end

    def confirmed_or_notified?
      confirmed? || notified?
    end

    def not_confirmed_or_notified?
      confirmed_or_notified?
    end

    def confirmed?
      confirmation.try :confirmed?
    end

    def notified?
      confirmation.try :confirmation_code_sent?
    end

    def unconfirmed?
      !confirmed?
    end

    def not_notified?
      !notified?
    end

    def build_confirmation_and_commit(current_user, user_performing = nil)
      build_confirmation(current_user, user_performing)
      confirm_without_code(current_user, user_performing)
    end

    def build_confirmation(current_user, user_performing = nil)
      confirmation || Confirmation.build_ballot_confirmation(self, current_user, user_performing)
    end

    def build_confirmation_with_code(current_user, user_performing = nil)
        confirmation_built = build_confirmation(current_user, user_performing)
        confirmation_built.send_confirmation_code(current_user, user_performing)
    end

    def resend_confirmation_code(current_user, user_performing = nil)
      confirmation.resend_confirmation_code current_user, user_performing
    end

    def confirm_without_code(current_user, user_performing = nil)
      confirm(nil, current_user, user_performing)
    end

    def confirm(code, current_user, user_performing = nil)
      confirmation.commit(code, current_user, user_performing)
    end

    def discard(current_user, user_performing = nil)
      Budget::Ballot.transaction do |t|
        # soft destroy confirmation
        confirmation.discard(current_user, user_performing)
        # remove lines
        lines.destroy_all
      end
    end

    #GET-107
    def group
      groups.first
    end

    def not_started?
      lines.empty?
    end

    def uncompleted?
      !completed!
    end

    def completed?
      if  group
        group.headings.all? { |h| completed_by_heading?(h) }
      end
    end

    def number_of_mandatory_lines
      if  group
        group.headings.inject(0) { |sum,h| number_of_mandatory_lines_to_complete(h) + sum }
      end
    end

    def completed_by_heading?(heading)

      number_remaining_lines_to_complete(heading) == 0
    end

    def number_remaining_lines_to_complete(heading)

      ballot_lines_count = lines.where(heading_id: heading.id).count
      number_of_mandatory_lines_to_complete(heading) - ballot_lines_count
    end

    def number_of_mandatory_lines_to_complete(heading)
      investments_count = heading.investments.selected.count
      [investments_count, MAX_LINES_PER_HEADING].min
    end

    def investment_points(investment)
      line = investment_line(investment)
      line ? line.points : 0
    end

    def investment_line(investment)
      lines.where(investment_id: investment.id).first
    end

    def sorted_investments(heading_id = nil)
      investments = lines.order(:points).collect(&:investment)
      investments = investments.select { |investment| investment.heading_id == heading_id } if heading_id
      investments
    end

    def add_investment(investment)
      lines.create(investment: investment).persisted?
    end

    def add_investment(investment, points)
      return true if investment_line(investment)
      lines.create!(investment: investment, points: points)
    end

    def total_amount_spent
      investments.sum(:price).to_i
    end

    def amount_spent(heading)
      investments.by_heading(heading.id).sum(:price).to_i
    end

    def formatted_amount_spent(heading)
      budget.formatted_amount(amount_spent(heading))
    end

    def amount_available(heading)
      budget.heading_price(heading) - amount_spent(heading)
    end

    def formatted_amount_available(heading)
      budget.formatted_amount(amount_available(heading))
    end

    def has_lines_in_group?(group)
      self.groups.include?(group)
    end

    def wrong_budget?(heading)
      heading.budget_id != budget_id
    end

    def different_heading_assigned?(heading)
      other_heading_ids = heading.group.heading_ids - [heading.id]
      lines.where(heading_id: other_heading_ids).exists?
    end

    def valid_heading?(heading)
      !wrong_budget?(heading) && !different_heading_assigned?(heading)
    end

    def has_lines_with_no_heading?
      investments.no_heading.count > 0
    end

    def has_lines_with_heading?
      self.heading_id.present?
    end

    def has_lines_in_heading?(heading)
      investments.by_heading(heading.id).any?
    end

    def has_investment?(investment)
      self.investment_ids.include?(investment.id)
    end

    def heading_for_group(group)
      return nil unless has_lines_in_group?(group)
      self.investments.where(group: group).first.heading
    end

    private

    def initialize_random_seed
      self[:random_seed] ||= rand(99)/100.0
    end


  end
end
