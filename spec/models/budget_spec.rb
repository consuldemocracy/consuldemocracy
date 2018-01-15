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
      expect(budget).not_to be_valid
    end

    it "produces auxiliary methods" do
      budget.phase = "drafting"
      expect(budget).to be_drafting

      budget.phase = "accepting"
      expect(budget).to be_accepting

      budget.phase = "reviewing"
      expect(budget).to be_reviewing

      budget.phase = "selecting"
      expect(budget).to be_selecting

      budget.phase = "valuating"
      expect(budget).to be_valuating

      budget.phase = "publishing_prices"
      expect(budget).to be_publishing_prices

      budget.phase = "balloting"
      expect(budget).to be_balloting

      budget.phase = "reviewing_ballots"
      expect(budget).to be_reviewing_ballots

      budget.phase = "finished"
      expect(budget).to be_finished
    end

    it "balloting_or_later?" do
      budget.phase = "drafting"
      expect(budget).not_to be_balloting_or_later

      budget.phase = "accepting"
      expect(budget).not_to be_balloting_or_later

      budget.phase = "reviewing"
      expect(budget).not_to be_balloting_or_later

      budget.phase = "selecting"
      expect(budget).not_to be_balloting_or_later

      budget.phase = "valuating"
      expect(budget).not_to be_balloting_or_later

      budget.phase = "publishing_prices"
      expect(budget).not_to be_balloting_or_later

      budget.phase = "balloting"
      expect(budget).to be_balloting_or_later

      budget.phase = "reviewing_ballots"
      expect(budget).to be_balloting_or_later

      budget.phase = "finished"
      expect(budget).to be_balloting_or_later
    end
  end

  describe "#current" do

    it "returns nil if there is only one budget and it is still in drafting phase" do
      budget = create(:budget, phase: "drafting")

      expect(Budget.current).to eq(nil)
    end

    it "returns the budget if there is only one and not in drafting phase" do
      budget = create(:budget, phase: "accepting")

      expect(Budget.current).to eq(budget)
    end

    it "returns the last budget created that is not in drafting phase" do
      old_budget      = create(:budget, phase: "finished",  created_at: 2.years.ago)
      previous_budget = create(:budget, phase: "accepting", created_at: 1.year.ago)
      current_budget  = create(:budget, phase: "accepting", created_at: 1.month.ago)
      next_budget     = create(:budget, phase: "drafting",  created_at: 1.week.ago)

      expect(Budget.current).to eq(current_budget)
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
      budget.phase = 'publishing_prices'
      expect(budget.investments_orders).to eq(['random', 'price'])
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

