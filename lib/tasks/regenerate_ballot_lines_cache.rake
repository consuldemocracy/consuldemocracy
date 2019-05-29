namespace :budgets do
  desc "Regenerate ballot_lines_count cache"
  task calculate_ballot_lines: :environment do
    Budget::Ballot.find_each do |ballot|
      Budget::Ballot.reset_counters ballot.id, :lines
    end
  end
end
