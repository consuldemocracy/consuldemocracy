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

end

def investments_author_emails(investments)
  User.where(id: investments.pluck(:author_id).uniq).pluck(:email).uniq
end

def winner_investments
  Budget::Investment.winners.where(budget: Budget.last)
end

def selected_non_winner_investments
  Budget::Investment.selected.where(budget: Budget.last).where.not(id: winner_investments.pluck(:id))
end

def non_selected_non_winner_investments
  Budget::Investment.where(budget: Budget.last).where.not(id: Budget::Investment.selected.pluck(:id))
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
