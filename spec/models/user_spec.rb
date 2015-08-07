require 'rails_helper'

describe User do

  describe "#votes_on_debates" do
    before(:each) do
      @user = create(:user)
    end

    it "should return {} if no debate" do
      expect(@user.votes_on_debates()).to eq({})
      expect(@user.votes_on_debates([])).to eq({})
      expect(@user.votes_on_debates([nil, nil])).to eq({})
    end

    it "should return a hash of debates ids and votes" do
      debate1 = create(:debate)
      debate2 = create(:debate)
      debate3 = create(:debate)
      create(:vote, voter: @user, votable: debate1, vote_flag: true)
      create(:vote, voter: @user, votable: debate3, vote_flag: false)

      voted = @user.votes_on_debates([debate1.id, debate2.id, debate3.id])

      expect(voted[debate1.id]).to eq(true)
      expect(voted[debate2.id]).to eq(nil)
      expect(voted[debate3.id]).to eq(false)
    end
  end

  subject { build(:user) }

  it "is valid" do
    expect(subject).to be_valid
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

end
