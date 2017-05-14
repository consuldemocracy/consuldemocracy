require 'rails_helper'

describe "Budget::Ballot::Line" do

  describe 'Validations' do
    let(:budget){ create(:budget) }
    let(:group){ create(:budget_group, budget: budget) }
    let(:heading){ create(:budget_heading, group: group, price: 10000000) }
    let(:investment){ create(:budget_investment, :selected, price: 5000000, heading: heading) }
    let(:ballot) { create(:budget_ballot, budget: budget) }
    let(:ballot_line) { build(:budget_ballot_line, ballot: ballot, investment: investment) }

    it "should be valid and automatically denormallyze budget, group and heading when validated" do
      expect(ballot_line).to be_valid
      expect(ballot_line.budget).to eq(budget)
      expect(ballot_line.group).to eq(group)
      expect(ballot_line.heading).to eq(heading)
    end

    describe 'Money' do
      it "should not be valid if insufficient funds" do
        investment.update(price: heading.price + 1)
        expect(ballot_line).to_not be_valid
      end

      it "should be valid if sufficient funds" do
        investment.update(price: heading.price - 1)
        expect(ballot_line).to be_valid
      end
    end

    describe 'Selectibility' do
      it "should not be valid if investment is unselected" do
        investment.update(selected: false)
        expect(ballot_line).to_not be_valid
      end

      it "should be valid if investment is selected" do
        investment.update(selected: true, price: 20000)
        expect(ballot_line).to be_valid
      end
    end

  end

  describe "#store_user_heading" do

    it "stores the heading where the user has voted" do
      allow_any_instance_of(Budget::Ballot::Line).
      to receive(:city_heading_id).and_return(-1)

      user = create(:user, :level_two)
      investment = create(:budget_investment, :selected)
      ballot = create(:budget_ballot, user: user, budget: investment.budget)

      create(:budget_ballot_line, ballot: ballot, investment: investment)

      expect(user.balloted_heading_id).to eq(investment.heading.id)
    end

    it "does not store the heading if voting in the whole city" do
      user = create(:user, :level_two)
      investment = create(:budget_investment, :selected)
      ballot = create(:budget_ballot, user: user, budget: investment.budget)

      allow_any_instance_of(Budget::Ballot::Line).
      to receive(:city_heading).and_return(investment.heading.id)

      create(:budget_ballot_line, ballot: ballot, investment: investment)

      expect(user.balloted_heading_id).to eq(nil)
    end

  end
end
