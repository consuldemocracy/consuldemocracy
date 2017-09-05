require 'rails_helper'

describe Follow do

  let(:follow) { build(:follow, :followed_proposal) }

  it "should be valid" do
    expect(follow).to be_valid
  end

  it "should not be valid without a user_id" do
    follow.user_id = nil
    expect(follow).to_not be_valid
  end

  it "should not be valid without a followable_id" do
    follow.followable_id = nil
    expect(follow).to_not be_valid
  end

  it "should not be valid without a followable_type" do
    follow.followable_type = nil
    expect(follow).to_not be_valid
  end

end
