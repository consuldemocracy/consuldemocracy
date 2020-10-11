require "rails_helper"

describe Budget do
  let(:budget) { create(:budget) }

  it_behaves_like "sluggable", updatable_slug_trait: :drafting
  it_behaves_like "reportable"
  it_behaves_like "globalizable", :budget

  describe "scopes" do
    describe ".open" do
      it "returns all budgets that are not in the finished phase" do
        (Budget::Phase::PHASE_KINDS - ["finished"]).each do |phase|
          budget = create(:budget, phase: phase)
          expect(Budget.open).to include(budget)
        end
      end
    end

    describe ".valuating_or_later" do
      it "returns budgets valuating or later" do
        valuating = create(:budget, :valuating)
        finished = create(:budget, :finished)

        expect(Budget.valuating_or_later).to match_array([valuating, finished])
      end

      it "does not return budgets which haven't reached valuation" do
        create(:budget, :drafting)
        create(:budget, :selecting)

        expect(Budget.valuating_or_later).to be_empty
      end
    end
  end

  describe "name" do
    before do
      budget.update(name_en: "object name")
    end

    it "must not be repeated for a different budget and same locale" do
      expect(build(:budget, name_en: "object name")).not_to be_valid
    end

    it "must not be repeated for a different budget and a different locale" do
      expect(build(:budget, name_fr: "object name")).not_to be_valid
    end

    it "may be repeated for the same budget and a different locale" do
      budget.update!(name_fr: "object name")
      expect(budget.translations.last).to be_valid
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
        end
      end
    end

    describe "With associated Budget::Phases" do
      before do
        budget.phases.each do |phase|
          phase.description = phase.kind.humanize
          phase.save!
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

      budget.phase = "inexisting"
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

    describe "#valuating_or_later?" do
      it "returns false before valuating" do
        budget.phase = "selecting"
        expect(budget).not_to be_valuating_or_later
      end

      it "returns true while valuating" do
        budget.phase = "valuating"
        expect(budget).to be_valuating_or_later
      end

      it "returns true after valuating" do
        budget.phase = "publishing_prices"
        expect(budget).to be_valuating_or_later
      end
    end

    describe "#publishing_prices_or_later?" do
      it "returns false before publishing prices" do
        budget.phase = "valuating"
        expect(budget).not_to be_publishing_prices_or_later
      end

      it "returns true while publishing prices" do
        budget.phase = "publishing_prices"
        expect(budget).to be_publishing_prices_or_later
      end

      it "returns true after publishing prices" do
        budget.phase = "balloting"
        expect(budget).to be_publishing_prices_or_later
      end
    end

    describe "#balloting_or_later?" do
      it "returns false before balloting" do
        budget.phase = "publishing_prices"
        expect(budget).not_to be_balloting_or_later
      end

      it "returns true while balloting" do
        budget.phase = "balloting"
        expect(budget).to be_balloting_or_later
      end

      it "returns true after balloting" do
        budget.phase = "finished"
        expect(budget).to be_balloting_or_later
      end
    end
  end

  describe "#current" do
    it "returns nil if there is only one budget and it is still in drafting phase" do
      create(:budget, :drafting)

      expect(Budget.current).to eq(nil)
    end

    it "returns the budget if there is only one and not in drafting phase" do
      budget = create(:budget, :accepting)

      expect(Budget.current).to eq(budget)
    end

    it "returns the last budget created that is not in drafting phase" do
      create(:budget, :finished,  created_at: 2.years.ago, name: "Old")
      create(:budget, :accepting, created_at: 1.year.ago,  name: "Previous")
      create(:budget, :accepting, created_at: 1.month.ago, name: "Current")
      create(:budget, :drafting,  created_at: 1.week.ago,  name: "Next")

      expect(Budget.current.name).to eq "Current"
    end
  end

  describe "heading_price" do
    it "returns the heading price if the heading provided is part of the budget" do
      heading = create(:budget_heading, price: 100, budget: budget)
      expect(budget.heading_price(heading)).to eq(100)
    end

    it "returns -1 if the heading provided is not part of the budget" do
      expect(budget.heading_price(create(:budget_heading))).to eq(-1)
    end
  end

  describe "investments_orders" do
    it "is random when accepting and reviewing" do
      budget.phase = "accepting"
      expect(budget.investments_orders).to eq(["random"])
      budget.phase = "reviewing"
      expect(budget.investments_orders).to eq(["random"])
    end
    it "is random and price when ballotting and reviewing ballots" do
      budget.phase = "publishing_prices"
      expect(budget.investments_orders).to eq(["random", "price"])
      budget.phase = "balloting"
      expect(budget.investments_orders).to eq(["random", "price"])
      budget.phase = "reviewing_ballots"
      expect(budget.investments_orders).to eq(["random", "price"])
    end
    it "is random and confidence_score in all other cases" do
      budget.phase = "selecting"
      expect(budget.investments_orders).to eq(["random", "confidence_score"])
      budget.phase = "valuating"
      expect(budget.investments_orders).to eq(["random", "confidence_score"])
    end
  end

  describe "#has_winning_investments?" do
    it "returns true if there is a winner investment" do
      budget.investments << build(:budget_investment, :winner, price: 3, ballot_lines_count: 2)

      expect(budget.has_winning_investments?).to eq true
    end

    it "hould return false if there is not a winner investment" do
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
    it "correctly formats Euros with Spanish" do
      budget.update!(currency_symbol: "€")
      I18n.locale = :es

      expect(budget.formatted_amount(1000.00)).to eq "1.000 €"
    end

    it "correctly formats Dollars with Spanish" do
      budget.update!(currency_symbol: "$")
      I18n.locale = :es

      expect(budget.formatted_amount(1000.00)).to eq "1.000 $"
    end

    it "correctly formats Dollars with English" do
      budget.update!(currency_symbol: "$")
      I18n.locale = :en

      expect(budget.formatted_amount(1000.00)).to eq "$1,000"
    end

    it "correctly formats Euros with English" do
      budget.update!(currency_symbol: "€")
      I18n.locale = :en

      expect(budget.formatted_amount(1000.00)).to eq "€1,000"
    end
  end

  describe "#investments_milestone_tags" do
    let(:investment1) { build(:budget_investment, :winner) }
    let(:investment2) { build(:budget_investment, :winner) }
    let(:investment3) { build(:budget_investment) }

    it "returns an empty array if not investments milestone_tags" do
      budget.investments << investment1

      expect(budget.investments_milestone_tags).to eq([])
    end

    it "returns array of investments milestone_tags" do
      investment1.milestone_tag_list = "tag1"
      investment1.save!
      budget.investments << investment1

      expect(budget.investments_milestone_tags).to eq(["tag1"])
    end

    it "returns uniq list of investments milestone_tags" do
      investment1.milestone_tag_list = "tag1"
      investment1.save!
      investment2.milestone_tag_list = "tag1"
      investment2.save!
      budget.investments << investment1
      budget.investments << investment2

      expect(budget.investments_milestone_tags).to eq(["tag1"])
    end

    it "returns tags only for winner investments" do
      investment1.milestone_tag_list = "tag1"
      investment1.save!
      investment3.milestone_tag_list = "tag2"
      investment3.save!
      budget.investments << investment1
      budget.investments << investment3

      expect(budget.investments_milestone_tags).to eq(["tag1"])
    end
  end

  describe "#voting_style" do
    context "Validations" do
      it { expect(build(:budget, :approval)).to be_valid }
      it { expect(build(:budget, :knapsack)).to be_valid }
      it { expect(build(:budget, voting_style: "Oups!")).not_to be_valid }
    end

    context "Related supportive methods" do
      describe "#approval_voting?" do
        it { expect(build(:budget, :approval).approval_voting?).to be true }
        it { expect(build(:budget, :knapsack).approval_voting?).to be false }
      end
    end

    context "Defaults" do
      it "defaults to knapsack voting style" do
        expect(build(:budget).voting_style).to eq "knapsack"
      end
    end
  end
end
