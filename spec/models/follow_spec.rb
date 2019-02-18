require "rails_helper"

describe Follow do

  let(:follow) { build(:follow, :followed_proposal) }

  it "is valid" do
    expect(follow).to be_valid
  end

  it "is not valid without a user_id" do
    follow.user_id = nil
    expect(follow).not_to be_valid
  end

  it "is not valid without a followable_id" do
    follow.followable_id = nil
    expect(follow).not_to be_valid
  end

  it "is not valid without a followable_type" do
    follow.followable_type = nil
    expect(follow).not_to be_valid
  end

end
