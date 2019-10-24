require "rails_helper"

describe DirectMessage do
  let(:direct_message) { build(:direct_message) }

  it "is valid" do
    expect(direct_message).to be_valid
  end

  it "is not valid without a title" do
    direct_message.title = nil
    expect(direct_message).not_to be_valid
  end

  it "is not valid without a body" do
    direct_message.body = nil
    expect(direct_message).not_to be_valid
  end

  it "is not valid without an associated sender" do
    direct_message.sender = nil
    expect(direct_message).not_to be_valid
  end

  it "is not valid without an associated receiver" do
    direct_message.receiver = nil
    expect(direct_message).not_to be_valid
  end

  describe "maximum number of direct messages per day" do
    context "when set" do
      before do
        Setting[:direct_message_max_per_day] = 3
      end

      it "is not valid if above maximum" do
        sender = create(:user)
        3.times { create(:direct_message, sender: sender) }

        direct_message4 = build(:direct_message, sender: sender)
        expect(direct_message4).not_to be_valid
      end

      it "is valid if below maximum" do
        sender = create(:user)
        2.times { create(:direct_message, sender: sender) }

        direct_message3 = build(:direct_message, sender: sender)
        expect(direct_message3).to be_valid
      end

      it "is valid if no direct_messages sent" do
        direct_message = build(:direct_message)

        expect(direct_message).to be_valid
      end
    end

    context "when unset" do
      before do
        Setting[:direct_message_max_per_day] = nil
      end

      it "is valid" do
        direct_message = build(:direct_message)

        expect(direct_message).to be_valid
      end
    end
  end

  describe "scopes" do
    describe "today", :with_non_utc_time_zone do
      it "returns direct messages created today" do
        create(:direct_message, created_at: Date.current.beginning_of_day)
        create(:direct_message, created_at: Time.current)
        create(:direct_message, created_at: Date.current.end_of_day)

        expect(DirectMessage.today.count).to eq 3
      end

      it "does not return direct messages created another day" do
        create(:direct_message, created_at: 1.day.ago)
        create(:direct_message, created_at: 1.day.from_now)

        expect(DirectMessage.today.count).to eq 0
      end
    end
  end
end
