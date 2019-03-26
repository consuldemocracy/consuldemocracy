require "rails_helper"

describe Budget::Stats do
  let(:budget) { create(:budget) }
  let(:stats) { Budget::Stats.new(budget) }
  let(:investment) { create(:budget_investment, :selected, budget: budget) }

  describe "#participants" do
    let(:author) { investment.author }
    let(:author_and_voter) { create(:user) }
    let(:voter) { create(:user) }
    let(:voter_and_balloter) { create(:user) }
    let(:balloter) { create(:user) }
    let(:poll_balloter) { create(:user, :level_two) }
    let(:non_participant) { create(:user, :level_two) }

    before do
      create(:budget_investment, :selected, budget: budget, author: author_and_voter)

      create(:vote, votable: investment, voter: author_and_voter)
      create(:vote, votable: investment, voter: voter)
      create(:vote, votable: investment, voter: voter_and_balloter)

      create(:budget_ballot_line, investment: investment, user: balloter)
      create(:budget_ballot_line, investment: investment, user: voter_and_balloter)

      create(:poll_voter, :from_booth, user: poll_balloter, budget: budget)

      create(:poll_voter, :from_booth, user: non_participant, budget: create(:budget))
    end

    it "returns unique participants, including authors" do
      expect(stats.participants).to match_array(
        [author, author_and_voter, voter, voter_and_balloter, balloter, poll_balloter]
      )
      expect(stats.generate[:total_participants]).to be 6
    end
  end

  describe "#total_participants_support_phase" do
    it "returns the number of total participants in the support phase" do
      2.times { create(:vote, votable: investment) }
      create(:budget_ballot_line, investment: investment)

      expect(stats.generate[:total_participants_support_phase]).to be 2
    end

    it "counts a user who is voter and balloter" do
      voter_and_balloter = create(:user)
      create(:vote, votable: investment, voter: voter_and_balloter)
      create(:budget_ballot_line, investment: investment, user: voter_and_balloter)

      expect(stats.generate[:total_participants_support_phase]).to be 1
    end
  end

  describe "#total_participants_vote_phase" do
    it "returns the number of total participants in the votes phase" do
      2.times { create(:budget_ballot_line, investment: investment) }
      create(:vote, votable: investment)

      expect(stats.generate[:total_participants_vote_phase]).to be 2
    end

    it "counts a user who is voter and balloter" do
      voter_and_balloter = create(:user)
      create(:vote, votable: investment, voter: voter_and_balloter)
      create(:budget_ballot_line, investment: investment, user: voter_and_balloter)

      expect(stats.generate[:total_participants_vote_phase]).to be 1
    end
  end

  describe "#total_participants_web" do
    it "returns the number of total participants in the votes phase via web" do
      2.times { create(:budget_ballot_line, investment: investment) }
      create(:poll_voter, :from_booth, budget: budget)

      expect(stats.generate[:total_participants_web]).to be 2
    end
  end

  describe "#total_participants_booths" do
    it "returns the number of total participants in the votes phase in booths" do
      2.times { create(:poll_voter, :from_booth, budget: budget) }
      create(:budget_ballot_line, investment: investment)

      expect(stats.generate[:total_participants_booths]).to be 2
    end
  end

  describe "#total_budget_investments" do
    it "returns the number of total budget investments" do
      2.times { create(:budget_investment, budget: budget) }
      create(:budget_investment, budget: create(:budget))

      expect(stats.generate[:total_budget_investments]).to be 2
    end
  end

  describe "#total_votes" do
    it "returns the number of total votes" do
      create(:budget_ballot_line, investment: investment)
      create(:budget_ballot_line, investment: create(:budget_investment, :selected, budget: budget))

      expect(stats.generate[:total_votes]).to be 2
    end
  end

  describe "#total_selected_investments" do
    it "returns the number of total selected investments" do
      3.times { create(:budget_investment, :selected, budget: budget) }
      create(:budget_investment, :selected, budget: create(:budget))
      create(:budget_investment, :unfeasible, budget: budget)

      expect(stats.generate[:total_selected_investments]).to be 3
    end
  end

  describe "#total_unfeasible_investments" do
    it "returns the number of total unfeasible investments" do
      3.times { create(:budget_investment, :unfeasible, budget: budget) }
      create(:budget_investment, :unfeasible, budget: create(:budget))
      create(:budget_investment, :selected, budget: budget)

      expect(stats.generate[:total_unfeasible_investments]).to be 3
    end
  end

  describe "#total_supports" do
    it "returns the number of total supports" do
      2.times { create(:vote, votable: investment) }

      expect(stats.generate[:total_supports]).to be 2
    end
  end

  describe "Participants by gender" do
    before do
      3.times { create(:user, gender: "male") }
      2.times { create(:user, gender: "female") }
      create(:user, gender: nil)

      allow(stats).to receive(:participants).and_return(User.all)
    end

    describe "#total_male_participants" do
      it "returns the number of total male participants" do
        expect(stats.generate[:total_male_participants]).to be 3
      end
    end

    describe "#total_female_participants" do
      it "returns the number of total female participants" do
        expect(stats.generate[:total_female_participants]).to be 2
      end
    end

    describe "#total_unknown_gender_or_age" do
      it "returns the number of total unknown participants' gender or age" do
        expect(stats.generate[:total_unknown_gender_or_age]).to be 1
      end
    end

    describe "#male_percentage" do
      it "returns the percentage of male participants" do
        expect(stats.generate[:male_percentage]).to be 60.0
      end
    end

    describe "#female_percentage" do
      it "returns the percentage of female participants" do
        expect(stats.generate[:female_percentage]).to be 40.0
      end
    end
  end

  describe "#participants_by_age" do
    before do
      [21, 22, 23, 23, 34, 42, 43, 44, 50, 51].each do |age|
        create(:user, date_of_birth: age.years.ago)
      end

      allow(stats).to receive(:participants).and_return(User.all)
    end

    it "returns the age groups hash" do
      expect(stats.generate[:participants_by_age]["16 - 19"][:count]).to be 0
      expect(stats.generate[:participants_by_age]["20 - 24"][:count]).to be 4
      expect(stats.generate[:participants_by_age]["25 - 29"][:count]).to be 0
      expect(stats.generate[:participants_by_age]["30 - 34"][:count]).to be 1
      expect(stats.generate[:participants_by_age]["35 - 39"][:count]).to be 0
      expect(stats.generate[:participants_by_age]["40 - 44"][:count]).to be 3
      expect(stats.generate[:participants_by_age]["45 - 49"][:count]).to be 0
      expect(stats.generate[:participants_by_age]["50 - 54"][:count]).to be 2
      expect(stats.generate[:participants_by_age]["55 - 59"][:count]).to be 0
      expect(stats.generate[:participants_by_age]["60 - 64"][:count]).to be 0
      expect(stats.generate[:participants_by_age]["65 - 69"][:count]).to be 0
      expect(stats.generate[:participants_by_age]["70 - 74"][:count]).to be 0
    end
  end

  describe "#headings" do
    before do
      investment.heading.update_column(:population, 1234)
      create(:budget_investment, heading: investment.heading)
      2.times { create(:vote, votable: investment) }
      create(:budget_ballot_line, investment: investment)
    end

    it "returns headings data" do
      heading_stats = stats.generate[:headings][investment.heading.id]
      expect(heading_stats[:total_investments_count]).to be 2
      expect(heading_stats[:total_participants_support_phase]).to be 2
      expect(heading_stats[:total_participants_vote_phase]).to be 1
      expect(heading_stats[:total_participants_all_phase]).to be 3
      expect(heading_stats[:percentage_participants_support_phase]).to be 100.0
      expect(heading_stats[:percentage_district_population_support_phase]).to be 0.162
      expect(heading_stats[:percentage_participants_vote_phase]).to be 100.0
      expect(heading_stats[:percentage_district_population_vote_phase]).to be 0.081
      expect(heading_stats[:percentage_participants_all_phase]).to be 100.0
      expect(heading_stats[:percentage_district_population_all_phase]).to be 0.243
    end
  end
end
