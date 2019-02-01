require "rails_helper"

describe Legislation::Proposal do
  let(:proposal) { build(:legislation_proposal) }

  it "is valid" do
    expect(proposal).to be_valid
  end

  it "is not valid without a process" do
    proposal.process = nil
    expect(proposal).not_to be_valid
  end

  it "is not valid without an author" do
    proposal.author = nil
    expect(proposal).not_to be_valid
  end

  it "is not valid without a title" do
    proposal.title = nil
    expect(proposal).not_to be_valid
  end

  it "is not valid without a summary" do
    proposal.summary = nil
    expect(proposal).not_to be_valid
  end

  describe "#hot_score" do
    let(:now) { Time.current }

    it "period is correctly calculated to get exact votes per day" do
      new_proposal = create(:legislation_proposal, created_at: 23.hours.ago)
      2.times { new_proposal.vote_by(voter: create(:user), vote: "yes") }
      expect(new_proposal.hot_score).to be 2

      old_proposal = create(:legislation_proposal, created_at: 25.hours.ago)
      2.times { old_proposal.vote_by(voter: create(:user), vote: "yes") }
      expect(old_proposal.hot_score).to be 1

      older_proposal = create(:legislation_proposal, created_at: 49.hours.ago)
      3.times { older_proposal.vote_by(voter: create(:user), vote: "yes") }
      expect(old_proposal.hot_score).to be 1
    end

    it "remains the same for not voted proposals" do
      new = create(:legislation_proposal, created_at: now)
      old = create(:legislation_proposal, created_at: 1.day.ago)
      older = create(:legislation_proposal, created_at: 2.month.ago)
      expect(new.hot_score).to be 0
      expect(old.hot_score).to be 0
      expect(older.hot_score).to be 0
    end

    it "increases for proposals with more positive votes" do
      more_positive_votes = create(:legislation_proposal)
      2.times { more_positive_votes.vote_by(voter: create(:user), vote: "yes") }

      less_positive_votes = create(:legislation_proposal)
      less_positive_votes.vote_by(voter: create(:user), vote: "yes")

      expect(more_positive_votes.hot_score).to be > less_positive_votes.hot_score
    end

    it "increases for proposals with the same amount of positive votes within less days" do
      newer_proposal = create(:legislation_proposal, created_at: now)
      5.times { newer_proposal.vote_by(voter: create(:user), vote: "yes") }

      older_proposal = create(:legislation_proposal, created_at: 1.day.ago)
      5.times { older_proposal.vote_by(voter: create(:user), vote: "yes") }

      expect(newer_proposal.hot_score).to be > older_proposal.hot_score
    end

    it "increases for proposals voted within the period (last month by default)" do
      newer_proposal = create(:legislation_proposal, created_at: 2.months.ago)
      20.times { create(:vote, votable: newer_proposal, created_at: 3.days.ago) }

      older_proposal = create(:legislation_proposal, created_at: 2.months.ago)
      20.times { create(:vote, votable: older_proposal, created_at: 40.days.ago) }

      expect(newer_proposal.hot_score).to be > older_proposal.hot_score
    end

    describe "actions which affect it" do

      let(:proposal) { create(:legislation_proposal) }

      before do
        5.times { proposal.vote_by(voter: create(:user), vote: "yes") }
        2.times { proposal.vote_by(voter: create(:user), vote: "no") }
      end

      it "increases with positive votes" do
        previous = proposal.hot_score
        3.times { proposal.vote_by(voter: create(:user), vote: "yes") }
        expect(previous).to be < proposal.hot_score
      end

      it "decreases with negative votes" do
        previous = proposal.hot_score
        3.times { proposal.vote_by(voter: create(:user), vote: "no") }
        expect(previous).to be > proposal.hot_score
      end
    end
  end
end
