require 'rails_helper'

describe Budget::Phase do

  let(:budget)       { create(:budget) }
  let(:first_phase)  { budget.phases.drafting }
  let(:second_phase) { budget.phases.accepting }
  let(:third_phase)  { budget.phases.reviewing }
  let(:fourth_phase) { budget.phases.selecting }
  let(:final_phase)  { budget.phases.finished}

  before do
    first_phase.update_attributes(starts_at: Date.current - 3.days, ends_at: Date.current - 1.day)
    second_phase.update_attributes(starts_at: Date.current - 1.days, ends_at: Date.current + 1.day)
    third_phase.update_attributes(starts_at: Date.current + 1.days, ends_at: Date.current + 3.day)
    fourth_phase.update_attributes(starts_at: Date.current + 3.days, ends_at: Date.current + 5.day)
  end

  describe "validates" do
    it "is not valid without a budget" do
      expect(build(:budget_phase, budget: nil)).not_to be_valid
    end

    describe "kind validations" do
      it "is not valid without a kind" do
        expect(build(:budget_phase, kind: nil)).not_to be_valid
      end

      it "is not valid with a kind not in valid budget phases" do
        expect(build(:budget_phase, kind: 'invalid_phase_kind')).not_to be_valid
      end

      it "is not valid with the same kind as another budget's phase" do
        expect(build(:budget_phase, budget: budget)).not_to be_valid
      end
    end

    describe "#dates_range_valid?" do
      it "is valid when start & end dates are different & consecutive" do
        first_phase.update_attributes(starts_at: Date.today, ends_at: Date.tomorrow)

        expect(first_phase).to be_valid
      end

      it "is not valid when dates are equal" do
        first_phase.update_attributes(starts_at: Date.today, ends_at: Date.today)

        expect(first_phase).not_to be_valid
      end

      it "is not valid when start date is later than end date" do
        first_phase.update_attributes(starts_at: Date.tomorrow, ends_at: Date.today)

        expect(first_phase).not_to be_valid
      end
    end
  end

  describe "next & prev enabled phases" do
    before do
      second_phase.update_attributes(enabled: false)
    end

    describe "#next_enabled_phase" do
      it "returns the right next enabled phase" do
        expect(first_phase.reload.next_enabled_phase).to eq(third_phase)
        expect(third_phase.reload.next_enabled_phase).to eq(fourth_phase)
        expect(final_phase.reload.next_enabled_phase).to eq(nil)
      end
    end

    describe "#prev_enabled_phase" do
      it "returns the right previous enabled phase" do
        expect(first_phase.reload.prev_enabled_phase).to eq(nil)
        expect(third_phase.reload.prev_enabled_phase).to eq(first_phase)
        expect(fourth_phase.reload.prev_enabled_phase).to eq(third_phase)
      end
    end
  end
end
