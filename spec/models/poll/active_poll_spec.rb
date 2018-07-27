require 'rails_helper'

describe ActivePoll do

  describe "#description" do
    it "returns the description if it was created" do
      expect(described_class.description).to be nil
      active_poll = create(:active_poll)
      expect(described_class.description).to eq active_poll.description
      create(:active_poll)
      expect(described_class.description).to eq active_poll.description
    end
  end
end
