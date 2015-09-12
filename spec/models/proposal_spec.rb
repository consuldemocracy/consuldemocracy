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

  it "should not be valid without an question" do
    proposal.question = nil
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

  describe "#editable?" do
    let(:proposal) { create(:proposal) }
    before(:each) {Setting.find_by(key: "max_votes_for_proposal_edit").update(value: 100)}

    it "should be true if proposal has no votes yet" do
      expect(proposal.total_votes).to eq(0)
      expect(proposal.editable?).to be true
    end

    it "should be true if proposal has less than limit votes" do
      create_list(:vote, 91, votable: proposal)
      expect(proposal.total_votes).to eq(91)
      expect(proposal.editable?).to be true
    end

    it "should be false if proposal has more than limit votes" do
      create_list(:vote, 102, votable: proposal)
      expect(proposal.total_votes).to eq(102)
      expect(proposal.editable?).to be false
    end
  end
end