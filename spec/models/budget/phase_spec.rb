require "rails_helper"

describe Budget::Phase do
  let(:budget)          { create(:budget) }
  let(:informing_phase) { budget.phases.informing }
  let(:accepting_phase) { budget.phases.accepting }
  let(:reviewing_phase) { budget.phases.reviewing }
  let(:finished_phase)  { budget.phases.finished }

  it_behaves_like "globalizable", :budget_phase

  describe "validates" do
    it "is not valid without a budget" do
      expect(build(:budget_phase, budget: nil)).not_to be_valid
    end

    it "is not valid without a start date" do
      phase = budget.phases.first
      phase.starts_at = nil
      expect(phase).not_to be_valid
    end

    it "is not valid without an end date" do
      phase = budget.phases.first
      phase.ends_at = nil
      expect(phase).not_to be_valid
    end

    describe "kind validations" do
      it "is not valid without a kind" do
        expect(build(:budget_phase, kind: nil)).not_to be_valid
      end

      it "is not valid with a kind not in valid budget phases" do
        expect(build(:budget_phase, kind: "invalid_phase_kind")).not_to be_valid
      end

      it "is not valid with the same kind as another budget's phase" do
        expect(build(:budget_phase, budget: budget)).not_to be_valid
      end
    end

    describe "description validations" do
      it "dynamically validates the maximum length" do
        stub_const("#{Budget::Phase}::DESCRIPTION_MAX_LENGTH", 3)

        informing_phase.description_en = "long"

        expect(informing_phase).not_to be_valid
      end
    end

    describe "#dates_range_valid?" do
      it "is valid when start & end dates are different & consecutive" do
        informing_phase.assign_attributes(starts_at: Date.current, ends_at: Date.tomorrow)

        expect(informing_phase).to be_valid
      end

      it "is not valid when dates are equal" do
        informing_phase.assign_attributes(starts_at: Date.current, ends_at: Date.current)

        expect(informing_phase).not_to be_valid
      end

      it "is not valid when start date is later than end date" do
        informing_phase.assign_attributes(starts_at: Date.tomorrow, ends_at: Date.current)

        expect(informing_phase).not_to be_valid
      end
    end

    describe "main_link_url" do
      it "is not required if main_link_text is not provided" do
        valid_budget = build(:budget, main_link_text: nil)

        expect(valid_budget).to be_valid
      end

      it "is required if main_link_text is provided" do
        invalid_budget = build(:budget, main_link_text: "link text")

        expect(invalid_budget).not_to be_valid
        expect(invalid_budget.errors.count).to be 1
        expect(invalid_budget.errors[:main_link_url].count).to be 1
        expect(invalid_budget.errors[:main_link_url].first).to eq "can't be blank"
      end

      it "is valid if main_link_text and main_link_url are both provided" do
        budget = build(:budget, main_link_text: "link text", main_link_url: "https://consulproject.org")

        expect(budget).to be_valid
      end
    end
  end

  describe "#save" do
    it "touches the budget when it's updated" do
      budget = create(:budget)

      travel(10.seconds) do
        budget.current_phase.update!(enabled: false)

        expect(budget.updated_at).to eq Time.current
      end
    end
  end

  describe "next & prev enabled phases" do
    before do
      accepting_phase.update!(enabled: false)
      %w[selecting reviewing_ballots balloting publishing_prices valuating].each do |phase|
        budget.phases.send(phase).update(enabled: false)
      end
    end

    describe "#next_enabled_phase" do
      it "returns the right next enabled phase" do
        expect(informing_phase.reload.next_enabled_phase).to eq(reviewing_phase)
        expect(reviewing_phase.reload.next_enabled_phase).to eq(finished_phase)
        expect(finished_phase.reload.next_enabled_phase).to eq(nil)
      end
    end

    describe "#prev_enabled_phase" do
      it "returns the right previous enabled phase" do
        expect(informing_phase.reload.prev_enabled_phase).to eq(nil)
        expect(reviewing_phase.reload.prev_enabled_phase).to eq(informing_phase)
        expect(finished_phase.reload.prev_enabled_phase).to eq(reviewing_phase)
      end
    end
  end
end
