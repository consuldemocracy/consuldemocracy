namespace :migrations do
  desc "Migrates context of valuation taggings"
  task valuation_taggings: :environment do
    ApplicationLogger.new.info "Updating valuation taggings context"
    Tagging.where(context: "valuation").update_all(context: "valuation_tags")
  end

  desc "Migrates budget staff"
  task budget_admins_and_valuators: :environment do
    ApplicationLogger.new.info "Updating budget administrators and valuators"
    Budget.find_each do |budget|
      investments = budget.investments.with_hidden

      budget.update!(
        administrator_ids: investments.where.not(administrator: nil).distinct.pluck(:administrator_id),
        valuator_ids: Budget::ValuatorAssignment.where(investment: investments).distinct.pluck(:valuator_id)
      )
    end
  end
end
