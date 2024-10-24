require "rails_helper"

describe VotesHelper do
  describe "#votes_percentage" do
    it "alwayses sum 100%" do
      debate = create(:debate)
      create_list(:vote, 8, votable: debate, vote_flag: true)
      create_list(:vote, 3, votable: debate, vote_flag: false)

      expect(votes_percentage("likes", debate)).to eq("72%")
      expect(votes_percentage("dislikes", debate)).to eq("28%")
    end
  end
end
