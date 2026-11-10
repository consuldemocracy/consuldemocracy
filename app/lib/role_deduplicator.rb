class RoleDeduplicator
  attr_reader :valid_role, :duplicate

  def initialize(valid_role, duplicate)
    @valid_role = valid_role
    @duplicate = duplicate
  end

  def deduplicate
    ActiveRecord::Base.transaction do
      deduplicate_associations
      duplicate.delete
    end
  end

  private

    def deduplicate_associations
      case valid_role
      when Administrator
        merge_administrator
      when Moderator
        merge_moderator
      when Poll::Officer
        merge_poll_officer
      when Valuator
        merge_valuator
      end
    end

    def merge_administrator
      budget_ids = BudgetAdministrator.where(administrator_id: valid_role.id).pluck(:budget_id)
      BudgetAdministrator.where(administrator: duplicate, budget_id: budget_ids).delete_all
      BudgetAdministrator.where(administrator: duplicate)
                         .where.not(budget_id: budget_ids)
                         .update_all(administrator_id: valid_role.id)

      Budget::Investment.where(administrator: duplicate).update_all(administrator_id: valid_role.id)
      Comment.where(administrator_id: duplicate.id).update_all(administrator_id: valid_role.id)
    end

    def merge_moderator
      Comment.where(moderator_id: duplicate.id).update_all(moderator_id: valid_role.id)
    end

    def merge_poll_officer
      Poll::OfficerAssignment.where(officer: duplicate).update_all(officer_id: valid_role.id)
      Poll::Voter.where(officer: duplicate).update_all(officer_id: valid_role.id)

      FailedCensusCall.where(poll_officer: duplicate)
                      .update_all(poll_officer_id: valid_role.id)
      Poll::Officer.reset_counters(valid_role.id, :failed_census_calls)

      shifts_data = Poll::Shift.where(officer_id: valid_role.id)
                               .pluck(:booth_id, :date, :task)
                               .to_set
      Poll::Shift.where(officer_id: duplicate.id).find_each do |shift|
        if shifts_data.include?([shift.booth_id, shift.date, shift.task])
          shift.delete
        else
          shift.update_column(:officer_id, valid_role.id)
        end
      end
    end

    def merge_valuator
      budget_ids = BudgetValuator.where(valuator_id: valid_role.id).pluck(:budget_id)
      BudgetValuator.where(valuator_id: duplicate.id, budget_id: budget_ids).delete_all
      BudgetValuator.where(valuator_id: duplicate.id)
                    .where.not(budget_id: budget_ids)
                    .update_all(valuator_id: valid_role.id)

      investment_ids = Budget::ValuatorAssignment.where(valuator_id: valid_role.id)
                                                 .pluck(:investment_id)
      Budget::ValuatorAssignment.where(valuator_id: duplicate.id, investment_id: investment_ids)
                                .delete_all
      Budget::ValuatorAssignment.where(valuator_id: duplicate.id)
                                .where.not(investment_id: investment_ids)
                                .update_all(valuator_id: valid_role.id)
      Valuator.reset_counters(valid_role.id, :valuator_assignments)

      investment_ids.each do |investment_id|
        Budget::Investment.reset_counters(investment_id, :valuator_assignments)
      end
    end
end
