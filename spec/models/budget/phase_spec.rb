require 'rails_helper'

describe Budget::Phase do

  let(:budget)       { create(:budget) }
  let(:first_phase)  { budget.phases.drafting }
  let(:second_phase)  { budget.phases.informing }
  let(:third_phase) { budget.phases.accepting }
  let(:fourth_phase)  { budget.phases.reviewing }
  let(:fifth_phase) { budget.phases.selecting }
  let(:final_phase) { budget.phases.finished}

  before do
    first_phase.update_attributes(starts_at: Date.current - 3.days, ends_at: Date.current - 1.day)
    second_phase.update_attributes(starts_at: Date.current - 1.days, ends_at: Date.current + 1.day)
    third_phase.update_attributes(starts_at: Date.current + 1.days, ends_at: Date.current + 3.day)
    fourth_phase.update_attributes(starts_at: Date.current + 3.days, ends_at: Date.current + 5.day)
    fifth_phase.update_attributes(starts_at: Date.current + 5.days, ends_at: Date.current + 7.day)
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

    describe "#prev_phase_dates_valid?" do
      let(:error) do
        "Start date must be later than the start date of the previous enabled phase"\
        " (Draft (Not visible to the public))"
      end

      it "is invalid when start date is same as previous enabled phase start date" do
        second_phase.assign_attributes(starts_at: second_phase.prev_enabled_phase.starts_at)

        expect(second_phase).not_to be_valid
        expect(second_phase.errors.messages[:starts_at]).to include(error)
      end

      it "is invalid when start date is earlier than previous enabled phase start date" do
        second_phase.assign_attributes(starts_at: second_phase.prev_enabled_phase.starts_at - 1.day)

        expect(second_phase).not_to be_valid
        expect(second_phase.errors.messages[:starts_at]).to include(error)
      end

      it "is valid when start date is in between previous enabled phase start & end dates" do
        second_phase.assign_attributes(starts_at: second_phase.prev_enabled_phase.starts_at + 1.day)

        expect(second_phase).to be_valid
      end

      it "is valid when start date is later than previous enabled phase end date" do
        second_phase.assign_attributes(starts_at: second_phase.prev_enabled_phase.ends_at + 1.day)

        expect(second_phase).to be_valid
      end
    end

    describe "#next_phase_dates_valid?" do
      let(:error) do
        "End date must be earlier than the end date of the next enabled phase (Accepting projects)"
      end

      it "is invalid when end date is same as next enabled phase end date" do
        second_phase.assign_attributes(ends_at: second_phase.next_enabled_phase.ends_at)

        expect(second_phase).not_to be_valid
        expect(second_phase.errors.messages[:ends_at]).to include(error)
      end

      it "is invalid when end date is later than next enabled phase end date" do
        second_phase.assign_attributes(ends_at: second_phase.next_enabled_phase.ends_at + 1.day)

        expect(second_phase).not_to be_valid
        expect(second_phase.errors.messages[:ends_at]).to include(error)
      end

      it "is valid when end date is in between next enabled phase start & end dates" do
        second_phase.assign_attributes(ends_at: second_phase.next_enabled_phase.ends_at - 1.day)

        expect(second_phase).to be_valid
      end

      it "is valid when end date is earlier than next enabled phase start date" do
        second_phase.assign_attributes(ends_at: second_phase.next_enabled_phase.starts_at - 1.day)

        expect(second_phase).to be_valid
      end
    end
  end

  describe "#adjust_date_ranges" do
    let(:prev_enabled_phase) { second_phase.prev_enabled_phase }
    let(:next_enabled_phase) { second_phase.next_enabled_phase }

    describe "when enabled" do
      it "adjusts previous enabled phase end date to its own start date" do
        expect(prev_enabled_phase.ends_at).to eq(second_phase.starts_at)
      end

      it "adjusts next enabled phase start date to its own end date" do
        expect(next_enabled_phase.starts_at).to eq(second_phase.ends_at)
      end
    end

    describe "when being enabled" do
      before do
        second_phase.update_attributes(enabled: false,
                                       starts_at: Date.current,
                                       ends_at:  Date.current + 2.days)
      end

      it "adjusts previous enabled phase end date to its own start date" do
        expect{
          second_phase.update_attributes(enabled: true)
        }.to change{
          prev_enabled_phase.ends_at.to_date
        }.to(Date.current)
      end

      it "adjusts next enabled phase start date to its own end date" do
        expect{
          second_phase.update_attributes(enabled: true)
        }.to change{
          next_enabled_phase.starts_at.to_date
        }.to(Date.current + 2.days)
      end
    end

    describe "when disabled" do
      before do
        second_phase.update_attributes(enabled: false)
      end

      it "doesn't change previous enabled phase end date" do
        expect {
          second_phase.update_attributes(starts_at: Date.current,
                                         ends_at:  Date.current + 2.days)
        }.not_to (change{ prev_enabled_phase.ends_at })
      end

      it "doesn't change next enabled phase start date" do
        expect{
          second_phase.update_attributes(starts_at: Date.current,
                                         ends_at:  Date.current + 2.days)
        }.not_to (change{ next_enabled_phase.starts_at })
      end
    end

    describe "when being disabled" do
      it "doesn't adjust previous enabled phase end date to its own start date" do
        expect {
          second_phase.update_attributes(enabled: false,
                                         starts_at: Date.current,
                                         ends_at:  Date.current + 2.days)
        }.not_to (change{ prev_enabled_phase.ends_at })
      end

      it "adjusts next enabled phase start date to its own start date" do
        expect {
          second_phase.update_attributes(enabled: false,
                                         starts_at: Date.current,
                                         ends_at:  Date.current + 2.days)
        }.to change{ next_enabled_phase.starts_at.to_date }.to(Date.current)
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

  describe "#sanitize_description" do
    it "removes not allowed html entities from the description" do
      expect{
        first_phase.update_attributes(description: '<p><a href="/"><b>a</b></a></p> <script>javascript</script>')
      }.to change{ first_phase.description }.to('<p><a href="/">a</a></p> javascript')
    end
  end
end
