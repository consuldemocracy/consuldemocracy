namespace :budgets do
  namespace :email do

    desc "Sends emails to authors of selected investments"
    task selected: :environment do
      Budget.current.email_selected
    end

    desc "Sends emails to authors of unselected investments"
    task unselected: :environment do
      Budget.current.email_unselected
    end

    desc "Get emails from last Budget's winner investments authors"
    task winner_investments_emails: :environment do
      puts winner_emails
    end

    desc "Get emails from last Budget's selected but not winner investments authors"
    task selected_investments_emails: :environment do
      puts selected_emails
    end

    desc "Get emails from last Budget's proposed but not selected investments authors"
    task proposed_non_selected_investments_emails: :environment do
      puts proposed_non_selected_emails
    end

  end

  desc "Get Budget Polls results to fill an excell"
  task budget_polls_results: :environment do
    require 'csv'

    csv_string = CSV.generate(col_sep: "^", row_sep: "*****") do |csv|
      BudgetPoll.find_each do |budget_poll|
        csv << [
          budget_poll.name,
          budget_poll.email,
          budget_poll.preferred_subject,
          budget_poll.collective ? 'Si' : 'No',
          budget_poll.public_worker ? 'Si' : 'No',
          budget_poll.proposal_author ? 'Si' : 'No',
          budget_poll.selected_proposal_author ? 'Si' : 'No'
        ]
      end
    end

    csv_string.delete!("\t")
    headers = "nombre^email^tema^colectivo^funcionario^autor^seleccionado*****"
    puts "#{headers}#{csv_string}"
  end

  namespace :phases do
    desc "Generates Phases for existing Budgets without them & migrates description_* attributes"
    task generate_missing: :environment do
      Budget.where.not(id: Budget::Phase.all.pluck(:budget_id).uniq.compact).each do |budget|
        Budget::Phase::PHASE_KINDS.each do |phase|
          Budget::Phase.create(
            budget: budget,
            kind: phase,
            description: budget.send("description_#{phase}"),
            prev_phase: budget.phases&.last,
            starts_at: budget.phases&.last&.ends_at || Date.current,
            ends_at: (budget.phases&.last&.ends_at || Date.current) + 1.month
          )
        end
      end
    end
  end
end

def investments_author_emails(investments)
  User.where(id: investments.pluck(:author_id).uniq).pluck(:email).uniq
end

def winner_investments
  Budget::Investment.winners.where(budget: Budget.current)
end

def selected_non_winner_investments
  Budget::Investment.selected.where(budget: Budget.current)
                    .where.not(id: winner_investments.pluck(:id))
end

def non_selected_non_winner_investments
  Budget::Investment.where(budget: Budget.current)
                    .where.not(id: Budget::Investment.selected.pluck(:id))
end

def winner_emails
  investments_author_emails(winner_investments)
end

def selected_emails
  investments_author_emails(selected_non_winner_investments) - winner_emails
end

def proposed_non_selected_emails
  investments_author_emails(non_selected_non_winner_investments) - selected_emails
end
