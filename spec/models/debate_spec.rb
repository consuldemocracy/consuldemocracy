require 'rails_helper'

describe Debate do

  before(:each) do
    @debate = build(:debate)
  end

  it "should be valid" do
    expect(@debate).to be_valid
  end

  it "should not be valid without a title" do
    @debate.title = nil
    expect(@debate).to_not be_valid
  end

  it "should not be valid without a description" do
    @debate.description = nil
    expect(@debate).to_not be_valid
  end

  it "should not be valid without accepting terms of service" do
    @debate.terms_of_service = nil
    expect(@debate).to_not be_valid
  end
  
end
