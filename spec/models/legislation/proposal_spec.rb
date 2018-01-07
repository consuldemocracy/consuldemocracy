require 'rails_helper'

describe Legislation::Proposal do
  let(:proposal) { build(:legislation_proposal) }

  it "is valid" do
    expect(proposal).to be_valid
  end

  it "is not valid without a process" do
    proposal.process = nil
    expect(proposal).not_to be_valid
  end

  it "is not valid without an author" do
    proposal.author = nil
    expect(proposal).not_to be_valid
  end

  it "is not valid without a title" do
    proposal.title = nil
    expect(proposal).not_to be_valid
  end

  it "is not valid without a summary" do
    proposal.summary = nil
    expect(proposal).not_to be_valid
  end

end
