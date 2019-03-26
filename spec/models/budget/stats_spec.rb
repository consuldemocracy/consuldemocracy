require "rails_helper"

describe Budget::Stats do

  before do
    @budget = create(:budget)
    @heading = create(:budget_heading, budget: @budget, price: 1000)

    @investment1 = create(:budget_investment, :selected, author: create(:user, gender: "female"),
                          heading: @heading, price: 200, ballot_lines_count: 900, winner: true)
    @investment2 = create(:budget_investment, :selected, author: create(:user, gender: "female"),
                          heading: @heading, price: 300, ballot_lines_count: 800, winner: true)
    @investment3 = create(:budget_investment, :selected, author: create(:user, gender: "female",
                          date_of_birth: 40.years.ago), heading: @heading, price: 400,
                          ballot_lines_count: 880, winner: true)
    @investment4 = create(:budget_investment, :selected, author: create(:user, gender: "male"),
                          heading: @heading, price: 100, ballot_lines_count: 915, winner: true)
    @investment5 = create(:budget_investment, :unfeasible, author: create(:user, gender: "male",
                          date_of_birth: 25.years.ago), heading: @heading)

    @support1 = create(:vote, votable: @investment1, voter: create(:user, gender: "male"))
    @support2 = create(:vote, votable: @investment2, voter: create(:user))

    @budget_ballot_line1 = create(:budget_ballot_line,
                                  user: create(:user, gender: "female", date_of_birth: 54.years.ago),
                                  investment: @investment1)
    @budget_ballot_line2 = create(:budget_ballot_line, user: create(:user, gender: "female"),
                                  investment: @investment2)
    @budget_ballot_line3 = create(:budget_ballot_line, user: create(:user, gender: "male"),
                                  investment: @investment3)

    @poll_voter = create(:poll_voter, :from_booth, budget: @budget)

    @budget_ballot4 = create(:budget_ballot, budget: @budget, physical: true, user: nil)
    @budget_ballot_line4 = create(:budget_ballot_line, ballot: @budget_ballot4,
                                  investment: @investment4)
  end

  let(:stats) { Budget::Stats.new(@budget).generate }

  context "#total_participants" do

    it "returns the number of total participants" do
      expect(stats[:total_participants]).to be 11
    end

  end

  context "#total_participants_support_phase" do

    it "returns the number of total participants in the support phase" do
      expect(stats[:total_participants_support_phase]).to be 2
    end

  end

  context "#total_participants_vote_phase" do

    it "returns the number of total participants in the votes phase" do
      expect(stats[:total_participants_vote_phase]).to be 4
    end

  end

  context "#total_participants_web" do

    it "returns the number of total participants in the votes phase via web" do
      expect(stats[:total_participants_web]).to be 3
    end

  end

  context "#total_participants_booths" do

    it "returns the number of total participants in the votes phase in booths" do
      expect(stats[:total_participants_booths]).to be 1
    end

  end

  context "#total_budget_investments" do

    it "returns the number of total budget investments" do
      expect(stats[:total_budget_investments]).to be 5
    end

  end

  context "#total_votes" do

    it "returns the number of total votes" do
      expect(stats[:total_votes]).to be 4
    end

  end

  context "#total_selected_investments" do

    it "returns the number of total selected investments" do
      expect(stats[:total_selected_investments]).to be 4
    end

  end

  context "#total_unfeasible_investments" do

    it "returns the number of total unfeasible investments" do
      expect(stats[:total_unfeasible_investments]).to be 1
    end

  end

  context "#total_male_participants" do

    it "returns the number of total male participants" do
      expect(stats[:total_male_participants]).to be 4
    end

  end

  context "#total_female_participants" do

    it "returns the number of total female participants" do
      expect(stats[:total_female_participants]).to be 6
    end

  end

  context "#total_supports" do

    it "returns the number of total supports" do
      expect(stats[:total_supports]).to be 2
    end

  end

  context "#total_unknown_gender_or_age" do

    it "returns the number of total unknown participants' gender or age" do
      expect(stats[:total_unknown_gender_or_age]).to be 1
    end

  end

  context "#participants_by_age" do

    it "returns the age groups hash" do
      expect(stats[:participants_by_age]["16 - 19"][:count]).to be 0
      expect(stats[:participants_by_age]["20 - 24"][:count]).to be 7
      expect(stats[:participants_by_age]["25 - 29"][:count]).to be 1
      expect(stats[:participants_by_age]["30 - 34"][:count]).to be 0
      expect(stats[:participants_by_age]["35 - 39"][:count]).to be 1
      expect(stats[:participants_by_age]["40 - 44"][:count]).to be 1
      expect(stats[:participants_by_age]["45 - 49"][:count]).to be 0
      expect(stats[:participants_by_age]["50 - 54"][:count]).to be 1
      expect(stats[:participants_by_age]["55 - 59"][:count]).to be 0
      expect(stats[:participants_by_age]["60 - 64"][:count]).to be 0
      expect(stats[:participants_by_age]["65 - 69"][:count]).to be 0
      expect(stats[:participants_by_age]["70 - 74"][:count]).to be 0
    end

  end

  context "#male_percentage" do

    it "returns the percentage of male participants" do
      expect(stats[:male_percentage]).to be 40.0
    end

  end

  context "#female_percentage" do

    it "returns the percentage of female participants" do
      expect(stats[:female_percentage]).to be 60.0
    end

  end

  context "#headings" do

    it "returns headings data" do
      heading_stats = stats[:headings][@heading.id]
      expect(heading_stats[:total_investments_count]).to be 5
      expect(heading_stats[:total_participants_support_phase]).to be 2
      expect(heading_stats[:total_participants_vote_phase]).to be 4
      expect(heading_stats[:total_participants_all_phase]).to be 6
      expect(heading_stats[:percentage_participants_support_phase]).to be 100.0
      expect(heading_stats[:percentage_district_population_support_phase]).to be 0.162
      expect(heading_stats[:percentage_participants_vote_phase]).to be 100.0
      expect(heading_stats[:percentage_district_population_vote_phase]).to be 0.324
      expect(heading_stats[:percentage_participants_all_phase]).to be 100.0
      expect(heading_stats[:percentage_district_population_all_phase]).to be 0.486

      expect(heading_stats[:total_investments_count]).to be 5
      expect(heading_stats[:total_participants_support_phase]).to be 2
      expect(heading_stats[:total_participants_vote_phase]).to be 4
      expect(heading_stats[:total_participants_all_phase]).to be 6
      expect(heading_stats[:percentage_participants_support_phase]).to be 100.0
      expect(heading_stats[:percentage_participants_vote_phase]).to be 100.0
      expect(heading_stats[:percentage_participants_all_phase]).to be 100.0
    end

  end

end
