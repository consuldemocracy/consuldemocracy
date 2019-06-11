namespace :budgets do
  desc "Regenerate ballot_lines_count cache"
  task calculate_ballot_lines: :environment do
    ApplicationLogger.new.info "Calculating ballot lines"

    Budget::Ballot.find_each.with_index do |ballot, index|
      Budget::Ballot.reset_counters ballot.id, :lines
      print "." if (index % 10_000).zero?
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
