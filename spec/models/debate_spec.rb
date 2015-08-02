require 'rails_helper'

describe Debate do

  before(:each) do
    @debate = build(:debate)
  end

  it "should be valid" do
    expect(@debate).to be_valid
  end

  it "should not be valid without an author" do
    @debate.author = nil
    expect(@debate).to_not be_valid
  end

  it "should not be valid without a title" do
    @debate.title = nil
    expect(@debate).to_not be_valid
  end

  it "should not be valid without a description" do
    @debate.description = nil
    expect(@debate).to_not be_valid
  end

  it "should sanitize the description" do
    @debate.description = "<script>alert('danger');</script>"
    @debate.valid?
    expect(@debate.description).to eq("alert('danger');")
  end

  it "should not be valid without accepting terms of service" do
    @debate.terms_of_service = nil
    expect(@debate).to_not be_valid
  end

  describe "#editable?" do
    before(:each) do
      @debate = create(:debate)
    end

    it "should be true if debate has no votes yet" do
      expect(@debate.total_votes).to eq(0)
      expect(@debate.editable?).to be true
    end

    it "should be false if debate has votes" do
      create(:vote, votable: @debate)
      expect(@debate.total_votes).to eq(1)
      expect(@debate.editable?).to be false
    end
  end

  describe "#editable_by?" do
    before(:each) do
      @debate = create(:debate)
    end

    it "should be true if user is the author and debate is editable" do
      expect(@debate.editable_by?(@debate.author)).to be true
    end

    it "should be false if debate is not editable" do
      create(:vote, votable: @debate)
      expect(@debate.editable_by?(@debate.author)).to be false
    end

    it "should be false if user is not the author" do
      expect(@debate.editable_by?(create(:user))).to be false

    end
  end

end
