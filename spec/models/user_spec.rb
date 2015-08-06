require 'rails_helper'

describe User do

  before(:each) do
    @user = create(:user)
  end

  describe "#votes_on_debates" do
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
end
