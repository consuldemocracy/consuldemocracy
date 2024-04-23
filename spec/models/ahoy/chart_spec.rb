require "rails_helper"

describe Ahoy::Chart do
  describe "#data_points" do
    it "raises an exception for unknown events" do
      chart = Ahoy::Chart.new(:mystery)

      expect { chart.data_points }.to raise_exception "Unknown event mystery"
    end

    it "returns data associated with the event" do
      time_1 = Time.zone.local(2015, 01, 01)
      time_2 = Time.zone.local(2015, 01, 02)
      time_3 = Time.zone.local(2015, 01, 03)

      create(:proposal, created_at: time_1)
      create(:proposal, created_at: time_1)
      create(:proposal, created_at: time_2)
      create(:debate, created_at: time_1)
      create(:debate, created_at: time_3)

      chart = Ahoy::Chart.new(:proposal_created)

      expect(chart.data_points).to eq x: ["2015-01-01", "2015-01-02"], "Proposal Created" => [2, 1]
    end

    it "accepts strings as the event name" do
      create(:proposal, created_at: Time.zone.local(2015, 01, 01))
      create(:debate, created_at: Time.zone.local(2015, 01, 02))

      chart = Ahoy::Chart.new("proposal_created")

      expect(chart.data_points).to eq x: ["2015-01-01"], "Proposal Created" => [1]
    end

    it "returns visits data for the visits event" do
      time_1 = Time.zone.local(2015, 01, 01)
      time_2 = Time.zone.local(2015, 01, 02)

      create(:visit, started_at: time_1)
      create(:visit, started_at: time_1)
      create(:visit, started_at: time_2)

      chart = Ahoy::Chart.new(:visits)

      expect(chart.data_points).to eq x: ["2015-01-01", "2015-01-02"], "Visits" => [2, 1]
    end

    it "returns user supports for the user_supported_budgets event" do
      time_1 = Time.zone.local(2017, 04, 01)
      time_2 = Time.zone.local(2017, 04, 02)

      create(:vote, votable: create(:budget_investment), created_at: time_1)
      create(:vote, votable: create(:budget_investment), created_at: time_2)
      create(:vote, votable: create(:budget_investment), created_at: time_2)
      create(:vote, votable: create(:proposal), created_at: time_2)

      chart = Ahoy::Chart.new(:user_supported_budgets)

      expect(chart.data_points).to eq x: ["2017-04-01", "2017-04-02"], "User Supported Budgets" => [1, 2]
    end

    it "returns level three verified dates for the level_3_user event" do
      time_1 = Time.zone.local(2001, 01, 01)
      time_2 = Time.zone.local(2001, 01, 02)

      create(:user, :level_two, level_two_verified_at: time_1)
      create(:user, :level_three, verified_at: time_2)
      create(:user, :level_three, verified_at: time_2, level_two_verified_at: time_1)

      chart = Ahoy::Chart.new(:level_3_user)

      expect(chart.data_points).to eq x: ["2001-01-02"], "Level 3 User" => [2]
    end
  end
end
