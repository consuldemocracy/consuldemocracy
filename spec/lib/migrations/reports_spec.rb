require "rails_helper"

describe Migrations::Reports do
  describe "#migrate" do
    it "ignores polls with existing reports" do
      create(:poll, results_enabled: true, stats_enabled: true) do |poll|
        poll.write_attribute(:results_enabled, false)
        poll.write_attribute(:stats_enabled, false)
        poll.save
      end

      Migrations::Reports.new.migrate

      expect(Poll.last.results_enabled).to be true
      expect(Poll.last.stats_enabled).to be true
      expect(Poll.last.advanced_stats_enabled).to be nil
    end

    it "migrates polls with no reports" do
      create(:poll) do |poll|
        poll.write_attribute(:results_enabled, true)
        poll.write_attribute(:stats_enabled, true)
        poll.save
      end

      Migrations::Reports.new.migrate

      expect(Poll.last.results_enabled).to be true
      expect(Poll.last.stats_enabled).to be true
      expect(Poll.last.advanced_stats_enabled).to be true
    end

    it "ignores budgets with existing reports" do
      create(:budget, results_enabled: false, stats_enabled: false, advanced_stats_enabled: false)

      Migrations::Reports.new.migrate

      expect(Budget.last.results_enabled).to be false
      expect(Budget.last.stats_enabled).to be false
      expect(Budget.last.advanced_stats_enabled).to be false
    end

    it "enables results and stats for every budget" do
      create(:budget)

      Migrations::Reports.new.migrate

      expect(Budget.last.results_enabled).to be true
      expect(Budget.last.stats_enabled).to be true
      expect(Budget.last.advanced_stats_enabled).to be true
    end
  end
end
