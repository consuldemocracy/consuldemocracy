require 'rails_helper'

describe Proposal do
  let(:proposal) { build(:proposal) }

  it "should be valid" do
    expect(proposal).to be_valid
  end

  it "should not be valid without an author" do
    proposal.author = nil
    expect(proposal).to_not be_valid
  end

  it "should not be valid without a title" do
    proposal.title = nil
    expect(proposal).to_not be_valid
  end

  describe "#description" do
    it "should be mandatory" do
      proposal.description = nil
      expect(proposal).to_not be_valid
    end

    it "should be sanitized" do
      proposal.description = "<script>alert('danger');</script>"
      proposal.valid?
      expect(proposal.description).to eq("alert('danger');")
    end
  end

  it "should sanitize the tag list" do
    proposal.tag_list = "user_id=1"
    proposal.valid?
    expect(proposal.tag_list).to eq(['user_id1'])
  end

  it "should not be valid without accepting terms of service" do
    proposal.terms_of_service = nil
    expect(proposal).to_not be_valid
  end
end