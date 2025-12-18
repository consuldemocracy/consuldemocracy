require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:event) { build(:event) }

  describe "Validations" do
    it "is valid with valid attributes" do
      expect(event).to be_valid
    end

    it "is invalid without a name" do
      event.name = nil
      expect(event).not_to be_valid
    end

    it "is invalid without a starts_at" do
      event.starts_at = nil
      expect(event).not_to be_valid
    end

    it "is invalid without an ends_at" do
      event.ends_at = nil
      expect(event).not_to be_valid
    end

    it "is invalid if ends_at is before starts_at" do
      event.starts_at = Date.tomorrow
      event.ends_at = Date.today
      expect(event).not_to be_valid
      expect(event.errors[:starts_at]).to include(I18n.t("errors.messages.invalid_date_range"))
    end

    it "is invalid with an unknown event_type" do
      event.event_type = "invalid_party_type"
      expect(event).not_to be_valid
    end

    it "is valid with a known event_type" do
      event.event_type = "workshop"
      expect(event).to be_valid
    end
  end

  describe "#human_type" do
    it "returns the translation for a known type" do
      event.event_type = "consultation"
      # Assuming you have translations, otherwise it humanizes
      expect(event.human_type).to eq "Consultation"
    end

    it "returns 'Manual Event' if event_type is blank" do
      event.event_type = nil
      expect(event.human_type).to eq "Manual Event"
    end
  end

  describe ".all_in_range" do
    let!(:past_event) { create(:event, starts_at: 1.month.ago, ends_at: 1.month.ago + 1.hour) }
    let!(:upcoming_event) { create(:event, starts_at: 1.day.from_now, ends_at: 2.days.from_now) }
    let!(:far_future_event) { create(:event, starts_at: 2.months.from_now, ends_at: 3.months.from_now) }

    it "returns manual events falling within the requested range" do
      # Range covers the upcoming_event
      start_range = Date.current
      end_range = 1.month.from_now

      results = Event.all_in_range(start_range, end_range)

      expect(results).to include(upcoming_event)
      expect(results).not_to include(past_event)
      expect(results).not_to include(far_future_event)
    end

    # Note: Testing Budget/Legislation integration usually requires
    # mocking those models or having full factories for them.
    # For unit tests, we primarily ensure the Event scope works.
  end
end
