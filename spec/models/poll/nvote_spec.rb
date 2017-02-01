require 'rails_helper'

describe Poll::Nvote do

  describe "validations" do
    let(:nvote) { build(:poll_nvote) }

    it "should be valid" do
      expect(nvote).to be_valid
    end

    it "should not be valid without a user" do
      nvote.user = nil
      expect(nvote).to_not be_valid
    end

    it "should not be valid without a poll" do
      nvote.poll = nil
      expect(nvote).to_not be_valid
    end

    it "should not be valid without a voter_hash" do
      nvote.save
      nvote.voter_hash = nil
      expect(nvote).to_not be_valid
    end

    it "should not be valid if already voted" do
      poll1 = create(:poll)
      poll2 = create(:poll)

      user = create(:user)

      nvote1 = create(:poll_nvote, user: user, poll: poll1)
      nvote2 = create(:poll_nvote, user: user, poll: poll2)

      nvote3 = build(:poll_nvote, user: user, poll: poll1)

      expect(nvote1).to be_valid
      expect(nvote2).to be_valid
      expect(nvote3).to_not be_valid
    end
  end

  describe "voter_hash" do

    it "should generate and save voter_hash on creation" do
      nvote = create(:poll_nvote)
      expect(nvote.voter_hash).to be
    end

    describe "#generate_voter_hash" do
      it "generates hash for voter_hash" do
        nvote = create(:poll_nvote)
        voter_hash = nvote.generate_voter_hash

        expect(voter_hash.length).to eq(64)
      end
    end

  end

  describe "#generate_message" do

    it "generates valid message" do
      poll = create(:poll, nvotes_poll_id: "1234")
      nvote = create(:poll_nvote, poll: poll)
      message  = nvote.generate_message

      expect(message.split(':')[0]).to eq(nvote.voter_hash)
      expect(message.split(':')[2]).to eq("1234")
      timestamp = message.split(':')[4].to_i
      expect(Time.at(timestamp).to_date).to eq(Date.today)
    end

  end

  describe "#generate_hash" do

    it "generates hash from message" do
      nvote = create(:poll_nvote)
      expect(nvote.generate_hash("test").length).to eq(64)
    end

  end

  describe "url" do

    it "generates url with vote information" do
      poll = create(:poll, nvotes_poll_id: "1234")
      nvote = create(:poll_nvote, poll: poll)

      expect(nvote.url).to start_with("https://")
      expect(nvote.url.length).to be > 64
      expect(nvote.url).to include "https://prevotsecdecide.madrid.es"
      expect(nvote.url).to include "booth/1234"
      expect(nvote.url).to include "vote/#{nvote.generate_hash(nvote.generate_message)}/#{nvote.generate_message}"
    end
  end

end