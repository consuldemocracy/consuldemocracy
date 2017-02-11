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

  context "callback on successful vote" do

    describe "#parse_authorization" do
      it "returns nvote and poll from an authorization message" do
        poll = create(:poll, nvotes_poll_id: 123)
        nvote = create(:poll_nvote, poll: poll)
        nvote.update(voter_hash: "33333333")

        message = "33333333:AuthEvent:123:RegisterSuccessfulLogin:1486030800"
        expect(Poll::Nvote.parse_authorization(message)).to eq([nvote, poll])
      end
    end

    describe "#store_voter" do
      it "stores a poll voter given a valid callback from Nvotes" do
        user  = create(:user, :in_census)
        poll = create(:poll, nvotes_poll_id: 123)
        nvote = create(:poll_nvote, user: user, poll: poll)
        nvote.update(voter_hash: "33333333")

        message = "33333333:AuthEvent:123:RegisterSuccessfulLogin:1486030800"
        signature = nvote.generate_hash(message)

        authorization_hash = "khmac:///sha-256;#{signature}/#{message}"
        Poll::Nvote.store_voter(authorization_hash)

        expect(Poll::Voter.count).to eq(1)
        expect(Poll::Voter.first.poll).to eq(poll)
        expect(Poll::Voter.first.user).to eq(user)
      end

      it "store demografic data of a poll voter" do
        geozone = create(:geozone, :in_census)
        user  = create(:user, :in_census, date_of_birth: 18.years.ago, gender: "female", geozone: geozone)

        poll = create(:poll)
        nvote = create(:poll_nvote, user: user, poll: poll)

        message = "1:AuthEvent:1:RegisterSuccessfulLogin:1"
        signature = nvote.generate_hash(message)

        authorization_hash = "khmac:///sha-256;#{signature}/#{message}"
        allow(Poll::Nvote).to receive(:parse_authorization).and_return([nvote, poll])

        Poll::Nvote.store_voter(authorization_hash)

        expect(Poll::Voter.count).to eq(1)
        expect(Poll::Voter.first.age).to eq(18)
        expect(Poll::Voter.first.gender).to eq("female")
        expect(Poll::Voter.first.geozone).to eq(geozone)
      end

      it "does not store voter if the signature is invalid" do
        user  = create(:user, :in_census)
        poll = create(:poll, nvotes_poll_id: 123)
        nvote = create(:poll_nvote, user: user, poll: poll)
        nvote.update(voter_hash: "33333333")

        message = "33333333:AuthEvent:123:RegisterSuccessfulLogin:1486030800"
        signature = "wrong_signature"

        authorization_hash = "khmac:///sha-256;#{signature}/#{message}"
        Poll::Nvote.store_voter(authorization_hash)

        expect(Poll::Voter.count).to eq(0)
      end
    end

    describe "#signature_valid?" do
      it "returns true if signature is valid" do
        allow(Poll).to receive(:server_shared_key).and_return("1234")
        nvote = build(:poll_nvote)

        message = "1:AuthEvent:1:RegisterSuccessfulLogin:1"
        signature = nvote.generate_hash(message)

        expect(Poll::Nvote.signature_valid?(signature, message)).to be(true)
      end

      it "returns false if signature is invalid" do
        allow(Poll).to receive(:server_shared_key).and_return("1234")
        nvote = build(:poll_nvote)

        message = "1:AuthEvent:1:RegisterSuccessfulLogin:1"
        signature = "1234"

        expect(Poll::Nvote.signature_valid?(signature, message)).to be(false)
      end

    end

  end
end