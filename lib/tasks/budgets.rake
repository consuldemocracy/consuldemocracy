namespace :budgets do
  desc "Regenerate ballot_lines_count cache"
  task calculate_ballot_lines: :environment do
    Budget::Ballot.find_each do |ballot|
      Budget::Ballot.reset_counters ballot.id, :lines
    end
  end

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

end
