require 'rails_helper'

describe User do

  describe "#debate_votes" do
    let(:user) { create(:user) }

    it "returns {} if no debate" do
      expect(user.debate_votes([])).to eq({})
    end

    it "returns a hash of debates ids and votes" do
      debate1 = create(:debate)
      debate2 = create(:debate)
      debate3 = create(:debate)
      create(:vote, voter: user, votable: debate1, vote_flag: true)
      create(:vote, voter: user, votable: debate3, vote_flag: false)

      voted = user.debate_votes([debate1, debate2, debate3])

      expect(voted[debate1.id]).to eq(true)
      expect(voted[debate2.id]).to eq(nil)
      expect(voted[debate3.id]).to eq(false)
    end
  end

  subject { build(:user) }

  it "is valid" do
    expect(subject).to be_valid
  end

  describe 'preferences' do
    describe 'email_on_debate_comment' do
      it 'should be false by default' do
        expect(subject.email_on_debate_comment).to eq(false)
      end
    end

    describe 'email_on_comment_reply' do
      it 'should be false by default' do
        expect(subject.email_on_comment_reply).to eq(false)
      end
    end
  end

  describe 'use_nickname' do
    describe 'when true' do
      before { subject.use_nickname = true }

      it "activates the validation of nickname" do
        subject.nickname = nil
        expect(subject).to_not be_valid

        subject.nickname = "dredd"
        expect(subject).to be_valid
      end

      it "calculates the name using the nickname" do
        subject.nickname = "dredd"
        expect(subject.name).to eq("dredd")
      end
    end

    describe 'when false' do
      before { subject.use_nickname = false }

      it "activates the validation of first_name and last_name" do
        subject.first_name = nil
        subject.last_name = nil
        expect(subject).to_not be_valid

        subject.first_name = "Joseph"
        subject.last_name = "Dredd"
        expect(subject).to be_valid
      end

      it "calculates the name using first_name and last_name" do
        subject.first_name = "Joseph"
        subject.last_name = "Dredd"
        expect(subject.name).to eq("Joseph Dredd")
      end
    end
  end

  describe "administrator?" do
    it "is false when the user is not an admin" do
      expect(subject.administrator?).to be false
    end

    it "is true when the user is an admin" do
      subject.save
      create(:administrator, user: subject)
      expect(subject.administrator?).to be true
    end
  end

  describe "moderator?" do
    it "is false when the user is not a moderator" do
      expect(subject.moderator?).to be false
    end

    it "is true when the user is a moderator" do
      subject.save
      create(:moderator, user: subject)
      expect(subject.moderator?).to be true
    end
  end

  describe "official?" do
    it "is false when the user is not an official" do
      expect(subject.official_level).to eq(0)
      expect(subject.official?).to be false
    end

    it "is true when the user is an official" do
      subject.official_level = 3
      subject.save
      expect(subject.official?).to be true
    end
  end

  describe "add_official_position!" do
    it "is false when level not valid" do
      expect(subject.add_official_position!("Boss", 89)).to be false
    end

    it "updates official position fields" do
      expect(subject).not_to be_official
      subject.add_official_position!("Veterinarian", 2)

      expect(subject).to be_official
      expect(subject.official_position).to eq("Veterinarian")
      expect(subject.official_level).to eq(2)

      subject.add_official_position!("Brain surgeon", 3)
      expect(subject.official_position).to eq("Brain surgeon")
      expect(subject.official_level).to eq(3)
    end
  end

  describe "remove_official_position!" do
    it "updates official position fields" do
      subject.add_official_position!("Brain surgeon", 3)
      expect(subject).to be_official

      subject.remove_official_position!

      expect(subject).not_to be_official
      expect(subject.official_position).to be_nil
      expect(subject.official_level).to eq(0)
    end
  end

end
