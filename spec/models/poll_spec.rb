require 'rails_helper'

describe :poll do

  let(:poll) { build(:poll) }

  it "should be valid" do
    expect(poll).to be_valid
  end

  it "should not be valid without a name" do
    poll.name = nil
    expect(poll).to_not be_valid
  end

end