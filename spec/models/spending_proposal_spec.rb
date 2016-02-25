require 'rails_helper'

describe SpendingProposal do
  let(:spending_proposal) { build(:spending_proposal) }

  it "should be valid" do
    expect(spending_proposal).to be_valid
  end

  it "should not be valid without an author" do
    spending_proposal.author = nil
    expect(spending_proposal).to_not be_valid
  end

  describe "#title" do
    it "should not be valid without a title" do
      spending_proposal.title = nil
      expect(spending_proposal).to_not be_valid
    end

    it "should not be valid when very short" do
      spending_proposal.title = "abc"
      expect(spending_proposal).to_not be_valid
    end

    it "should not be valid when very long" do
      spending_proposal.title = "a" * 81
      expect(spending_proposal).to_not be_valid
    end
  end

  describe "#description" do
    it "should be sanitized" do
      spending_proposal.description = "<script>alert('danger');</script>"
      spending_proposal.valid?
      expect(spending_proposal.description).to eq("alert('danger');")
    end

    it "should not be valid when very long" do
      spending_proposal.description = "a" * 6001
      expect(spending_proposal).to_not be_valid
    end
  end

  describe "dossier info" do
    describe "#feasibility" do
      it "can be feasible" do
        spending_proposal.feasible = true
        expect(spending_proposal.feasibility).to eq "feasible"
      end

      it "can be not-feasible" do
        spending_proposal.feasible = false
        expect(spending_proposal.feasibility).to eq "not_feasible"
      end

      it "can be undefined" do
        spending_proposal.feasible = nil
        expect(spending_proposal.feasibility).to eq "undefined"
      end
    end
  end


  describe "scopes" do
    describe "without_admin" do
      it "should return all spending proposals without assigned admin" do
        spending_proposal1 = create(:spending_proposal)
        spending_proposal2 = create(:spending_proposal, administrator: create(:administrator))

        without_admin = SpendingProposal.without_admin

        expect(without_admin.size).to eq(1)
        expect(without_admin.first).to eq(spending_proposal1)
      end
    end

    describe "without_valuators" do
      it "should return all spending proposals without assigned valuators" do
        spending_proposal1 = create(:spending_proposal)
        spending_proposal2 = create(:spending_proposal)
        spending_proposal1.valuators << create(:valuator)

        without_admin = SpendingProposal.without_valuators

        expect(without_admin.size).to eq(1)
        expect(without_admin.first).to eq(spending_proposal2)
      end
    end
  end

end
