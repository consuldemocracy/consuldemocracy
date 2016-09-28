require 'rails_helper'

describe :booth do

  let(:booth) { build(:poll_booth) }

  it "should be valid" do
    expect(booth).to be_valid
  end

  it "should not be valid without a name" do
    booth.name = nil
    expect(booth).to_not be_valid
  end

end