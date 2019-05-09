require "rails_helper"

describe Legislation::PeopleProposal do
  let(:people_proposal) { build(:legislation_people_proposal) }

  it "is valid" do
    expect(people_proposal).to be_valid
  end

  it "is not valid without a process" do
    people_proposal.process = nil
    expect(people_proposal).not_to be_valid
  end

  it "is not valid without an author" do
    people_proposal.author = nil
    expect(people_proposal).not_to be_valid
  end

  it "is not valid without a title" do
    people_proposal.title = nil
    expect(people_proposal).not_to be_valid
  end

  it "is not valid without a summary" do
    people_proposal.summary = nil
    expect(people_proposal).not_to be_valid
  end

  describe "#hot_score" do
    let(:now) { Time.current }

    it "period is correctly calculated to get exact votes per day" do
      new_people_proposal = create(:legislation_people_proposal, created_at: 23.hours.ago)
      2.times { new_people_proposal.vote_by(voter: create(:user), vote: "yes") }
      expect(new_people_proposal.hot_score).to be 2

      old_people_proposal = create(:legislation_people_proposal, created_at: 25.hours.ago)
      2.times { old_people_proposal.vote_by(voter: create(:user), vote: "yes") }
      expect(old_people_proposal.hot_score).to be 1

      older_people_proposal = create(:legislation_people_proposal, created_at: 49.hours.ago)
      3.times { older_people_proposal.vote_by(voter: create(:user), vote: "yes") }
      expect(old_people_proposal.hot_score).to be 1
    end

    it "remains the same for not voted people_proposals" do
      new = create(:legislation_people_proposal, created_at: now)
      old = create(:legislation_people_proposal, created_at: 1.day.ago)
      older = create(:legislation_people_proposal, created_at: 2.month.ago)
      expect(new.hot_score).to be 0
      expect(old.hot_score).to be 0
      expect(older.hot_score).to be 0
    end

    it "increases for people_proposals with more positive votes" do
      more_positive_votes = create(:legislation_people_proposal)
      2.times { more_positive_votes.vote_by(voter: create(:user), vote: "yes") }

      less_positive_votes = create(:legislation_people_proposal)
      less_positive_votes.vote_by(voter: create(:user), vote: "yes")

      expect(more_positive_votes.hot_score).to be > less_positive_votes.hot_score
    end

    it "increases for people_proposals with the same amount of positive votes within less days" do
      newer_people_proposal = create(:legislation_people_proposal, created_at: now)
      5.times { newer_people_proposal.vote_by(voter: create(:user), vote: "yes") }

      older_people_proposal = create(:legislation_people_proposal, created_at: 1.day.ago)
      5.times { older_people_proposal.vote_by(voter: create(:user), vote: "yes") }

      expect(newer_people_proposal.hot_score).to be > older_people_proposal.hot_score
    end

    it "increases for people_proposals voted within the period (last month by default)" do
      newer_people_proposal = create(:legislation_people_proposal, created_at: 2.months.ago)
      20.times { create(:vote, votable: newer_people_proposal, created_at: 3.days.ago) }

      older_people_proposal = create(:legislation_people_proposal, created_at: 2.months.ago)
      20.times { create(:vote, votable: older_people_proposal, created_at: 40.days.ago) }

      expect(newer_people_proposal.hot_score).to be > older_people_proposal.hot_score
    end

    describe "actions which affect it" do

      let(:people_proposal) { create(:legislation_people_proposal) }

      before do
        5.times { people_proposal.vote_by(voter: create(:user), vote: "yes") }
        2.times { people_proposal.vote_by(voter: create(:user), vote: "no") }
      end

      it "increases with positive votes" do
        previous = people_proposal.hot_score
        3.times { people_proposal.vote_by(voter: create(:user), vote: "yes") }
        expect(previous).to be < people_proposal.hot_score
      end

      it "decreases with negative votes" do
        previous = people_proposal.hot_score
        3.times { people_proposal.vote_by(voter: create(:user), vote: "no") }
        expect(previous).to be > people_proposal.hot_score
      end
    end
  end
end
