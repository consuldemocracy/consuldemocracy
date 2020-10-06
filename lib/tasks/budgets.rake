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

  desc "Update existing budgets in drafting phase"
  task update_drafting_budgets: :environment do
    Budget.where(phase: "drafting").each do |budget|
      budget.update!(phase: "informing", published: false)
    end
    if Budget.where(phase: "drafting").present?
      Budget::Phase.where(kind: "drafting").destroy_all
    end
  end
end
