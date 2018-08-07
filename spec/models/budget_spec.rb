require 'rails_helper'

describe Budget do

  let(:budget) { create(:budget) }

  it_behaves_like "sluggable", updatable_slug_trait: :drafting

  describe "name" do
    before do
      create(:budget, name: 'object name')
    end

    it "is validated for uniqueness" do
      expect(build(:budget, name: 'object name')).not_to be_valid
    end
  end

  describe "description" do
    describe "Without Budget::Phase associated" do
      before do
        budget.phases.destroy_all
      end

      it "changes depending on the phase, falling back to budget description attributes" do
        Budget::Phase::PHASE_KINDS.each do |phase_kind|
          budget.phase = phase_kind
          expect(budget.description).to eq(budget.send("description_#{phase_kind}"))
          expect(budget.description).to be_html_safe
        end
      end
    end

    describe "With associated Budget::Phases" do
      before do
        budget.phases.each do |phase|
          phase.description = phase.kind.humanize
          phase.save
        end
      end

      it "changes depending on the phase" do
        Budget::Phase::PHASE_KINDS.each do |phase_kind|
          budget.phase = phase_kind
          expect(budget.description).to eq(phase_kind.humanize)
        end
      end
    end
  end

  describe "phase" do
    it "is validated" do
      Budget::Phase::PHASE_KINDS.each do |phase|
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

      expect(described_class.current).to eq(nil)
    end

    it "returns the budget if there is only one and not in drafting phase" do
      budget = create(:budget, phase: "accepting")

      expect(described_class.current).to eq(budget)
    end

    it "returns the last budget created that is not in drafting phase" do
      old_budget      = create(:budget, phase: "finished",  created_at: 2.years.ago)
      previous_budget = create(:budget, phase: "accepting", created_at: 1.year.ago)
      current_budget  = create(:budget, phase: "accepting", created_at: 1.month.ago)
      next_budget     = create(:budget, phase: "drafting",  created_at: 1.week.ago)

      expect(described_class.current).to eq(current_budget)
    end

  end

  describe "#open" do

    it "returns all budgets that are not in the finished phase" do
      (Budget::Phase::PHASE_KINDS - ["finished"]).each do |phase|
        budget = create(:budget, phase: phase)
        expect(described_class.open).to include(budget)
      end
    end

  end

  describe "heading_price" do
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

  describe '#has_winning_investments?' do
    it 'should return true if there is a winner investment' do
      budget.investments << build(:budget_investment, :winner, price: 3, ballot_lines_count: 2)

      expect(budget.has_winning_investments?).to eq true
    end

    it 'hould return false if there is not a winner investment' do
      expect(budget.has_winning_investments?).to eq false
    end
  end

  describe "#generate_phases" do
    let(:drafting_phase)          { budget.phases.drafting }
    let(:informing_phase)         { budget.phases.informing }
    let(:accepting_phase)         { budget.phases.accepting }
    let(:reviewing_phase)         { budget.phases.reviewing }
    let(:selecting_phase)         { budget.phases.selecting }
    let(:valuating_phase)         { budget.phases.valuating }
    let(:publishing_prices_phase) { budget.phases.publishing_prices }
    let(:balloting_phase)         { budget.phases.balloting }
    let(:reviewing_ballots_phase) { budget.phases.reviewing_ballots }
    let(:finished_phase)          { budget.phases.finished }

    it "generates all phases linked in correct order" do
      expect(budget.phases.count).to eq(Budget::Phase::PHASE_KINDS.count)

      expect(drafting_phase.next_phase).to eq(informing_phase)
      expect(informing_phase.next_phase).to eq(accepting_phase)
      expect(accepting_phase.next_phase).to eq(reviewing_phase)
      expect(reviewing_phase.next_phase).to eq(selecting_phase)
      expect(selecting_phase.next_phase).to eq(valuating_phase)
      expect(valuating_phase.next_phase).to eq(publishing_prices_phase)
      expect(publishing_prices_phase.next_phase).to eq(balloting_phase)
      expect(balloting_phase.next_phase).to eq(reviewing_ballots_phase)
      expect(reviewing_ballots_phase.next_phase).to eq(finished_phase)
      expect(finished_phase.next_phase).to eq(nil)

      expect(drafting_phase.prev_phase).to eq(nil)
      expect(informing_phase.prev_phase).to eq(drafting_phase)
      expect(accepting_phase.prev_phase).to eq(informing_phase)
      expect(reviewing_phase.prev_phase).to eq(accepting_phase)
      expect(selecting_phase.prev_phase).to eq(reviewing_phase)
      expect(valuating_phase.prev_phase).to eq(selecting_phase)
      expect(publishing_prices_phase.prev_phase).to eq(valuating_phase)
      expect(balloting_phase.prev_phase).to eq(publishing_prices_phase)
      expect(reviewing_ballots_phase.prev_phase).to eq(balloting_phase)
      expect(finished_phase.prev_phase).to eq(reviewing_ballots_phase)
    end
  end

  describe "#formatted_amount" do
    after do
      I18n.locale = :en
    end

    it "correctly formats Euros with Spanish" do
      budget.update(currency_symbol: '€')
      I18n.locale = :es

      expect(budget.formatted_amount(1000.00)).to eq ('1.000 €')
    end

    it "correctly formats Dollars with Spanish" do
      budget.update(currency_symbol: '$')
      I18n.locale = :es

      expect(budget.formatted_amount(1000.00)).to eq ('1.000 $')
    end

    it "correctly formats Dollars with English" do
      budget.update(currency_symbol: '$')
      I18n.locale = :en

      expect(budget.formatted_amount(1000.00)).to eq ('$1,000')
    end

    it "correctly formats Euros with English" do
      budget.update(currency_symbol: '€')
      I18n.locale = :en

      expect(budget.formatted_amount(1000.00)).to eq ('€1,000')
    end
  end
end
