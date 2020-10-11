require "rails_helper"

describe Budget::Ballot::Line do
  let(:budget) { create(:budget) }
  let(:group) { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group, price: 10000000) }
  let(:investment) { create(:budget_investment, :selected, price: 5000000, heading: heading) }
  let(:ballot) { create(:budget_ballot, budget: budget) }
  let(:ballot_line) { build(:budget_ballot_line, ballot: ballot, investment: investment) }

  describe "Validations" do
    it "is valid and automatically denormallyze budget, group and heading when validated" do
      expect(ballot_line).to be_valid
      expect(ballot_line.budget).to eq(budget)
      expect(ballot_line.group).to eq(group)
      expect(ballot_line.heading).to eq(heading)
    end

    describe "Money" do
      it "is not valid if insufficient funds" do
        investment.update!(price: heading.price + 1)
        expect(ballot_line).not_to be_valid
      end

      it "is valid if sufficient funds" do
        investment.update!(price: heading.price - 1)
        expect(ballot_line).to be_valid
      end

      it "validates sufficient funds when creating lines at the same time", :race_condition do
        investment.update!(price: heading.price)
        other_investment = create(:budget_investment, :selected, price: heading.price, heading: heading)
        other_line = build(:budget_ballot_line, ballot: ballot, investment: other_investment)

        [ballot_line, other_line].map do |line|
          Thread.new { line.save }
        end.each(&:join)

        expect(Budget::Ballot::Line.count).to be 1
      end
    end

    describe "Approval voting" do
      before do
        budget.update!(voting_style: "approval")
        heading.update!(max_ballot_lines: 1)
      end

      it "is valid if there are votes left" do
        expect(ballot_line).to be_valid
      end

      it "is not valid if there are no votes left" do
        create(:budget_ballot_line, ballot: ballot,
               investment: create(:budget_investment, :selected, heading: heading))

        expect(ballot_line).not_to be_valid
      end

      it "is valid if insufficient funds but enough votes" do
        investment.update!(price: heading.price + 1)

        expect(ballot_line).to be_valid
      end

      it "validates votes when creating lines at the same time", :race_condition do
        other_investment = create(:budget_investment, :selected, heading: heading)
        other_line = build(:budget_ballot_line, ballot: ballot, investment: other_investment)

        [ballot_line, other_line].map do |line|
          Thread.new { line.save }
        end.each(&:join)

        expect(Budget::Ballot::Line.count).to be 1
      end
    end

    describe "Selectibility" do
      it "is not valid if investment is unselected" do
        investment.update!(selected: false)
        expect(ballot_line).not_to be_valid
      end

      it "is valid if investment is selected" do
        investment.update!(selected: true, price: 20000)
        expect(ballot_line).to be_valid
      end
    end
  end

  describe "#store_user_heading" do
    it "stores the heading where the user has voted" do
      user = create(:user, :level_two)
      investment = create(:budget_investment, :selected)
      ballot = create(:budget_ballot, user: user, budget: investment.budget)

      create(:budget_ballot_line, ballot: ballot, investment: investment)

      expect(user.reload.balloted_heading_id).to eq(investment.heading.id)
    end
  end

  describe "scopes" do
    describe "by_investment" do
      it "returns ballot lines for an investment" do
        investment1 = create(:budget_investment, :selected, heading: heading)
        investment2 = create(:budget_investment, :selected, heading: heading)

        ballot1 = create(:budget_ballot, budget: budget)
        ballot2 = create(:budget_ballot, budget: budget)
        ballot3 = create(:budget_ballot, budget: budget)

        ballot_line1 = create(:budget_ballot_line, ballot: ballot1, investment: investment1)
        ballot_line2 = create(:budget_ballot_line, ballot: ballot2, investment: investment1)
        ballot_line3 = create(:budget_ballot_line, ballot: ballot3, investment: investment2)

        ballot_lines_by_investment = Budget::Ballot::Line.by_investment(investment1.id)

        expect(ballot_lines_by_investment).to match_array [ballot_line1, ballot_line2]
        expect(ballot_lines_by_investment).not_to include ballot_line3
      end
    end
  end
end
