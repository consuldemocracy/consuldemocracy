require 'rails_helper'

describe Budget do

  it_behaves_like "sluggable"

  describe "name" do
    before do
      create(:budget, name: 'object name')
    end

    it "is validated for uniqueness" do
      expect(build(:budget, name: 'object name')).not_to be_valid
    end
  end

  describe "description" do
    it "changes depending on the phase" do
      budget = create(:budget)

      Budget::PHASES.each do |phase|
        budget.phase = phase
        expect(budget.description).to eq(budget.send("description_#{phase}"))
        expect(budget.description).to be_html_safe
      end
    end
  end

  describe "phase" do
    let(:budget) { create(:budget) }

    it "is validated" do
      Budget::PHASES.each do |phase|
        budget.phase = phase
        expect(budget).to be_valid
      end

      budget.phase = 'inexisting'
      expect(budget).to_not be_valid
    end

    it "produces auxiliary methods" do
      budget.phase = "accepting"
      expect(budget).to be_accepting

      budget.phase = "reviewing"
      expect(budget).to be_reviewing

      budget.phase = "selecting"
      expect(budget).to be_selecting

      budget.phase = "valuating"
      expect(budget).to be_valuating

      budget.phase = "balloting"
      expect(budget).to be_balloting

      budget.phase = "reviewing_ballots"
      expect(budget).to be_reviewing_ballots

      budget.phase = "finished"
      expect(budget).to be_finished
    end

    it "on_hold?" do
      budget.phase = "accepting"
      expect(budget).to_not be_on_hold

      budget.phase = "reviewing"
      expect(budget).to be_on_hold

      budget.phase = "selecting"
      expect(budget).to_not be_on_hold

      budget.phase = "valuating"
      expect(budget).to be_on_hold

      budget.phase = "balloting"
      expect(budget).to_not be_on_hold

      budget.phase = "reviewing_ballots"
      expect(budget).to be_on_hold

      budget.phase = "finished"
      expect(budget).to_not be_on_hold
    end

    it "balloting_or_later?" do
      budget.phase = "accepting"
      expect(budget).to_not be_balloting_or_later

      budget.phase = "reviewing"
      expect(budget).to_not be_balloting_or_later

      budget.phase = "selecting"
      expect(budget).to_not be_balloting_or_later

      budget.phase = "valuating"
      expect(budget).to_not be_balloting_or_later

      budget.phase = "balloting"
      expect(budget).to be_balloting_or_later

      budget.phase = "reviewing_ballots"
      expect(budget).to be_balloting_or_later

      budget.phase = "finished"
      expect(budget).to be_balloting_or_later
    end
  end

  describe "heading_price" do
    let(:budget) { create(:budget) }
    let(:group) { create(:budget_group, budget: budget) }

    it "returns the heading price if the heading provided is part of the budget" do
      heading = create(:budget_heading, price: 100, group: group)
      expect(budget.heading_price(heading)).to eq(100)
    end

    it "returns -1 if the heading provided is not part of the budget" do
      expect(budget.heading_price(create(:budget_heading))).to eq(-1)
    end
  end

  describe "investments_orders" do
    let(:budget) { create(:budget) }
    it "is random when accepting and reviewing" do
      budget.phase = 'accepting'
      expect(budget.investments_orders).to eq(['random'])
      budget.phase = 'reviewing'
      expect(budget.investments_orders).to eq(['random'])
    end
    it "is random and price when ballotting and reviewing ballots" do
      budget.phase = 'balloting'
      expect(budget.investments_orders).to eq(['random', 'price'])
      budget.phase = 'reviewing_ballots'
      expect(budget.investments_orders).to eq(['random', 'price'])
    end
    it "is random and confidence_score in all other cases" do
      budget.phase = 'selecting'
      expect(budget.investments_orders).to eq(['random', 'confidence_score'])
      budget.phase = 'valuating'
      expect(budget.investments_orders).to eq(['random', 'confidence_score'])
    end
  end
end

