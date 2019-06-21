class Migrations::Reports
  def migrate
    migrate_polls
    migrate_budgets
  end

  private

    def migrate_polls
      Poll.find_each do |poll|
        next unless poll.report.new_record?

        poll.report.update!(
          results:        poll.read_attribute(:results_enabled),
          stats:          poll.read_attribute(:stats_enabled),
          advanced_stats: poll.read_attribute(:stats_enabled),
        )
    end

    end

    def migrate_budgets
      Budget.find_each do |budget|
        next unless budget.report.new_record?

        budget.report.update!(results: true, stats: true, advanced_stats: true)
      end
    end
end
