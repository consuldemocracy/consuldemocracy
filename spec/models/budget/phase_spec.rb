require 'rails_helper'

describe Budget::Phase do

  let(:budget) { create(:budget) }

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
        create(:budget_phase, budget: budget)

        expect(build(:budget_phase, budget: budget)).not_to be_valid
      end
    end

    describe "#dates_range_valid?" do
      it "is valid when start & end dates are different & consecutive" do
        expect(build(:budget_phase, starts_at: Date.today, ends_at: Date.tomorrow)).to be_valid
      end

      it "is not valid when dates are equal" do
        expect(build(:budget_phase, starts_at: Date.today, ends_at: Date.today)).not_to be_valid
      end

      it "is not valid when start date is later than end date" do
        expect(build(:budget_phase, starts_at: Date.tomorrow, ends_at: Date.today)).not_to be_valid
      end
    end

  end

end
