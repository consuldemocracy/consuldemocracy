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

    describe "#prev_phase_dates_valid?" do
      let(:error) do
        "Start date must be later than the start date of the previous enabled phase (Information)"
      end

      it "is invalid when start date is same as previous enabled phase start date" do
        accepting_phase.assign_attributes(starts_at: accepting_phase.prev_enabled_phase.starts_at)

        expect(accepting_phase).not_to be_valid
        expect(accepting_phase.errors.messages[:starts_at]).to include(error)
      end

      it "is invalid when start date is earlier than previous enabled phase start date" do
        accepting_phase.assign_attributes(starts_at: accepting_phase.prev_enabled_phase.starts_at - 1.day)

        expect(accepting_phase).not_to be_valid
        expect(accepting_phase.errors.messages[:starts_at]).to include(error)
      end

      it "is valid when start date is in between previous enabled phase start & end dates" do
        accepting_phase.assign_attributes(starts_at: accepting_phase.prev_enabled_phase.starts_at + 1.day)

        expect(accepting_phase).to be_valid
      end

      it "is valid when start date is later than previous enabled phase end date" do
        accepting_phase.assign_attributes(starts_at: accepting_phase.prev_enabled_phase.ends_at + 1.day)

        expect(accepting_phase).to be_valid
      end
    end

    describe "#next_phase_dates_valid?" do
      let(:error) do
        "End date must be earlier than the end date of the next enabled phase (Accepting projects)"
      end

      it "is invalid when end date is same as next enabled phase end date" do
        informing_phase.assign_attributes(ends_at: informing_phase.next_enabled_phase.ends_at)

        expect(informing_phase).not_to be_valid
        expect(informing_phase.errors.messages[:ends_at]).to include(error)
      end

      it "is invalid when end date is later than next enabled phase end date" do
        informing_phase.assign_attributes(ends_at: informing_phase.next_enabled_phase.ends_at + 1.day)

        expect(informing_phase).not_to be_valid
        expect(informing_phase.errors.messages[:ends_at]).to include(error)
      end

      it "is valid when end date is in between next enabled phase start & end dates" do
        informing_phase.assign_attributes(ends_at: informing_phase.next_enabled_phase.ends_at - 1.day)

        expect(informing_phase).to be_valid
      end

      it "is valid when end date is earlier than next enabled phase start date" do
        informing_phase.assign_attributes(ends_at: informing_phase.next_enabled_phase.starts_at - 1.day)

        expect(informing_phase).to be_valid
      end
    end

    describe "main_button_url" do
      it "is not required if main_button_text is not provided" do
        valid_budget = build(:budget,
                             name_en: "object name",
                             main_button_text: "button text",
                             main_button_url: "http://domain.com")

        expect(valid_budget).to be_valid
      end

      it "is required if main_button_text is provided" do
        invalid_budget = build(:budget,
                               name_en: "object name",
                               main_button_text: "button text")

        expect(invalid_budget).not_to be_valid
        expect(invalid_budget.errors.count).to be 1
        expect(invalid_budget.errors[:main_button_url].count).to be 1
        expect(invalid_budget.errors[:main_button_url].first).to eq "can't be blank"
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

  describe "#adjust_date_ranges" do
    let(:prev_enabled_phase) { accepting_phase.prev_enabled_phase }
    let(:next_enabled_phase) { accepting_phase.next_enabled_phase }

    describe "when enabled" do
      it "adjusts previous enabled phase end date to its own start date" do
        expect(prev_enabled_phase.ends_at).to eq(accepting_phase.starts_at)
      end

      it "adjusts next enabled phase start date to its own end date" do
        expect(next_enabled_phase.starts_at).to eq(accepting_phase.ends_at)
      end
    end

    describe "when being enabled" do
      before do
        accepting_phase.update!(enabled: false,
                             starts_at: Date.current,
                             ends_at:  Date.current + 2.days)
      end

      it "adjusts previous enabled phase end date to its own start date" do
        expect { accepting_phase.update(enabled: true) }
          .to change { prev_enabled_phase.ends_at.to_date }.to(Date.current)
      end

      it "adjusts next enabled phase start date to its own end date" do
        expect do
          accepting_phase.update(enabled: true)
        end.to change { next_enabled_phase.starts_at.to_date }.to(Date.current + 2.days)
      end
    end

    describe "when disabled" do
      before do
        accepting_phase.update!(enabled: false)
      end

      it "doesn't change previous enabled phase end date" do
        expect { accepting_phase.update(starts_at: Date.current, ends_at:  Date.current + 2.days) }
          .not_to change { prev_enabled_phase.ends_at }
      end

      it "doesn't change next enabled phase start date" do
        expect { accepting_phase.update(starts_at: Date.current, ends_at:  Date.current + 2.days) }
          .not_to change { next_enabled_phase.starts_at }
      end
    end

    describe "when being disabled" do
      it "doesn't adjust previous enabled phase end date to its own start date" do
        expect do
          accepting_phase.update(enabled: false,
                              starts_at: Date.current,
                              ends_at:  Date.current + 2.days)
        end.not_to change { prev_enabled_phase.ends_at }
      end

      it "adjusts next enabled phase start date to its own start date" do
        expect do
          accepting_phase.update(enabled: false,
                              starts_at: Date.current,
                              ends_at:  Date.current + 2.days)
        end.to change { next_enabled_phase.starts_at.to_date }.to(Date.current)
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
