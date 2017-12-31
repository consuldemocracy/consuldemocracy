require 'rails_helper'

describe Legislation::Proposal do
  let(:proposal) { build(:legislation_proposal) }

  it "should be valid" do
    expect(proposal).to be_valid
  end

  it "should not be valid without a process" do
    proposal.process = nil
    expect(proposal).to_not be_valid
  end

  it "should not be valid without an author" do
    proposal.author = nil
    expect(proposal).to_not be_valid
  end

  it "should not be valid without a title" do
    proposal.title = nil
    expect(proposal).to_not be_valid
  end

  it "should not be valid without a summary" do
    proposal.summary = nil
    expect(proposal).to_not be_valid
  end

end
