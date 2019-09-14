require "rails_helper"

describe ScoreCalculator do
  describe ".hot_score" do
    let(:resource) { create(:debate) }

    before do
      resource.vote_by(voter: create(:user), vote: "yes")
    end

    it "ignores small time leaps", :with_frozen_time do
      resource.created_at = Time.current + 0.01

      expect(ScoreCalculator.hot_score(resource)).to eq 1
    end

    it "ignores setting with negative value " do
      Setting["hot_score_period_in_days"] = -1

      expect(ScoreCalculator.hot_score(resource)).to eq 1
    end

    it "ignores setting with zero value" do
      Setting["hot_score_period_in_days"] = 0

      expect(ScoreCalculator.hot_score(resource)).to eq 1
    end
  end
end
