namespace :budgets do
  namespace :email do
    desc "Sends emails to authors of selected investments"
    task selected: :environment do
      Budget.last.email_selected
    end

    desc "Sends emails to authors of unselected investments"
    task unselected: :environment do
      Budget.last.email_unselected
    end
  end

  desc "Set published attribute"
  task set_published: :environment do
    Budget.where(published: nil).each do |budget|
      if budget.phase == "drafting"
        if budget.phases.enabled.first.present?
          next_enabled_phase = budget.phases.enabled.where.not(kind: "drafting").first.kind
        else
          next_enabled_phase = "informing"
          budget.phases.informing.update!(enabled: true)
        end

        budget.update!(phase: next_enabled_phase)
        budget.update!(published: false)
      else
        budget.update!(published: true)
      end
    end
  end
end
