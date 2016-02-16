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
    describe "#legality" do
      it "can be legal" do
        spending_proposal.legal = true
        expect(spending_proposal.legality).to eq "legal"
      end

      it "can be no-legal" do
        spending_proposal.legal = false
        expect(spending_proposal.legality).to eq "no_legal"
      end

      it "can be undefined" do
        spending_proposal.legal = nil
        expect(spending_proposal.legality).to eq "undefined"
      end
    end

    describe "#feasibility" do
      it "can be feasible" do
        spending_proposal.feasible = true
        expect(spending_proposal.feasibility).to eq "feasible"
      end

      it "can be no-feasible" do
        spending_proposal.feasible = false
        expect(spending_proposal.feasibility).to eq "no_feasible"
      end

      it "can be undefined" do
        spending_proposal.feasible = nil
        expect(spending_proposal.feasibility).to eq "undefined"
      end
    end
  end

  describe "resolution status" do
    it "should be valid" do
      spending_proposal.resolution = "accepted"
      expect(spending_proposal).to be_valid
      spending_proposal.resolution = "rejected"
      expect(spending_proposal).to be_valid
      spending_proposal.resolution = "wrong"
      expect(spending_proposal).to_not be_valid
    end

    it "can be accepted" do
      spending_proposal.accept
      expect(spending_proposal.reload.resolution).to eq("accepted")
    end

    it "can be rejected" do
      spending_proposal.reject
      expect(spending_proposal.reload.resolution).to eq("rejected")
    end

    describe "#accepted?" do
      it "should be true if resolution equals 'accepted'" do
        spending_proposal.resolution = "accepted"
        expect(spending_proposal.accepted?).to eq true
      end

      it "should be false otherwise" do
        spending_proposal.resolution = "rejected"
        expect(spending_proposal.accepted?).to eq false
        spending_proposal.resolution = nil
        expect(spending_proposal.accepted?).to eq false
      end
    end

    describe "#rejected?" do
      it "should be true if resolution equals 'rejected'" do
        spending_proposal.resolution = "rejected"
        expect(spending_proposal.rejected?).to eq true
      end

      it "should be false otherwise" do
        spending_proposal.resolution = "accepted"
        expect(spending_proposal.rejected?).to eq false
        spending_proposal.resolution = nil
        expect(spending_proposal.rejected?).to eq false
      end
    end

    describe "#unresolved?" do
      it "should be true if resolution is blank" do
        spending_proposal.resolution = nil
        expect(spending_proposal.unresolved?).to eq true
      end

      it "should be false otherwise" do
        spending_proposal.resolution = "accepted"
        expect(spending_proposal.unresolved?).to eq false
        spending_proposal.resolution = "rejected"
        expect(spending_proposal.unresolved?).to eq false
      end
    end
  end

  describe "scopes" do
    before(:each) do
      2.times { create(:spending_proposal, resolution: "accepted") }
      2.times { create(:spending_proposal, resolution: "rejected") }
      2.times { create(:spending_proposal, resolution: nil) }
    end

    describe "unresolved" do
      it "should return all spending proposals without resolution" do
        unresolved = SpendingProposal.all.unresolved
        expect(unresolved.size).to eq(2)
        unresolved.each {|u| expect(u.resolution).to be_nil}
      end
    end

    describe "accepted" do
      it "should return all accepted spending proposals" do
        accepted = SpendingProposal.all.accepted
        expect(accepted.size).to eq(2)
        accepted.each {|a| expect(a.resolution).to eq("accepted")}
      end
    end

    describe "rejected" do
      it "should return all rejected spending proposals" do
        rejected = SpendingProposal.all.rejected
        expect(rejected.size).to eq(2)
        rejected.each {|r| expect(r.resolution).to eq("rejected")}
      end
    end
  end

end
