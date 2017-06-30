require 'rails_helper'

describe Follow do

  let(:follow) { build(:follow, :followed_proposal) }

  it "should be valid" do
    expect(follow).to be_valid
  end

  it "should not be valid without an user_id" do
    follow.user_id = nil
    expect(follow).to_not be_valid
  end

  it "should not be valid without an followable_id" do
    follow.followable_id = nil
    expect(follow).to_not be_valid
  end

  it "should not be valid without an followable_type" do
    follow.followable_type = nil
    expect(follow).to_not be_valid
  end

  describe "interests" do

    let(:user)     { create(:user) }

    it "interests_by user" do
      proposal =  create(:proposal, tag_list: "Sport")
      create(:follow, :followed_proposal, followable: proposal, user: user)

      expect(Follow.interests_by(user)).to eq ["Sport"]
    end

  end

end
