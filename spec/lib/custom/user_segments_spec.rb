require "rails_helper"

describe UserSegments do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }

  describe ".valid_segment?" do
    it "returns true with custom segments" do
      expect(UserSegments.valid_segment?("investment_followers")).to be true
    end
  end

  describe ".investment_followers" do
    it "returns users that follow a budget investment" do
      investment1 = create(:budget_investment)
      investment2 = create(:budget_investment)
      budget1 = create(:budget)
      budget2 = create(:budget)
      investment1.update!(budget: budget1)
      investment2.update!(budget: budget2)

      create(:follow, followable: investment1, user: user1)
      create(:follow, followable: investment2, user: user2)

      investment_followers = UserSegments.investment_followers

      expect(investment_followers).to eq [user2]
    end

    it "does not return duplicated users" do
      investment1 = create(:budget_investment)
      investment2 = create(:budget_investment)
      budget = create(:budget)
      investment1.update!(budget: budget)
      investment2.update!(budget: budget)

      create(:follow, followable: investment1, user: user1)
      create(:follow, followable: investment2, user: user1)

      investment_followers = UserSegments.investment_followers
      expect(investment_followers).to eq [user1]
    end
  end
end
