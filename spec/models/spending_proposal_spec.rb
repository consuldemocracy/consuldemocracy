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

    describe "#unfeasible?" do
      it "returns true when not feasible" do
        spending_proposal.feasible = false
        expect(spending_proposal.unfeasible?).to eq true
      end

      it "returns false when feasible" do
        spending_proposal.feasible = true
        expect(spending_proposal.unfeasible?).to eq false
      end
    end

    describe "#marked_as_unfeasible?" do
      let(:spending_proposal) { create(:spending_proposal) }

      it "returns true when feasibility has changed and it is false" do
        spending_proposal.update(feasible: false)
        expect(spending_proposal.marked_as_unfeasible?).to eq true
      end

      it "returns false when feasibility has not changed" do
        spending_proposal.update(price: 1000000)
        expect(spending_proposal.marked_as_unfeasible?).to eq false
      end

      it "returns false when it is feasible" do
        spending_proposal.update(feasible: true)
        expect(spending_proposal.marked_as_unfeasible?).to eq false
      end

      xit "when marked as unfeasible but there is no admin associated...
           an exception occurs when sending the unfeasible email,
           because spending_proposal.administrator.id is nil.."
    end

    describe "#code" do
      let(:spending_proposal) { create(:spending_proposal) }

      it "returns the proposal id" do
        expect(spending_proposal.code).to eq("#{spending_proposal.id}")
      end

      it "returns the administrator id when assigned" do
        spending_proposal.administrator = create(:administrator)
        expect(spending_proposal.code).to eq("#{spending_proposal.id}-A#{spending_proposal.administrator.id}")
      end
    end
  end

  describe "by_admin" do
    it "should return spending proposals assigned to specific administrator" do
      spending_proposal1 = create(:spending_proposal, administrator_id: 33)
      spending_proposal2 = create(:spending_proposal)

      by_admin = SpendingProposal.by_admin(33)

      expect(by_admin.size).to eq(1)
      expect(by_admin.first).to eq(spending_proposal1)
    end
  end

  describe "by_valuator" do
    it "should return spending proposals assigned to specific valuator" do
      spending_proposal1 = create(:spending_proposal)
      spending_proposal2 = create(:spending_proposal)
      spending_proposal3 = create(:spending_proposal)

      valuator1 = create(:valuator)
      valuator2 = create(:valuator)

      spending_proposal1.valuators << valuator1
      spending_proposal2.valuators << valuator2
      spending_proposal3.valuators << [valuator1, valuator2]

      by_valuator = SpendingProposal.by_valuator(valuator1.id)

      expect(by_valuator.size).to eq(2)
      expect(by_valuator.sort).to eq([spending_proposal1,spending_proposal3].sort)
    end
  end

  describe "scopes" do
    describe "valuation_open" do
      it "should return all spending proposals with false valuation_finished" do
        spending_proposal1 = create(:spending_proposal, valuation_finished: true)
        spending_proposal2 = create(:spending_proposal)

        valuation_open = SpendingProposal.valuation_open

        expect(valuation_open.size).to eq(1)
        expect(valuation_open.first).to eq(spending_proposal2)
      end
    end

    describe "without_admin" do
      it "should return all open spending proposals without assigned admin" do
        spending_proposal1 = create(:spending_proposal, valuation_finished: true)
        spending_proposal2 = create(:spending_proposal, administrator: create(:administrator))
        spending_proposal3 = create(:spending_proposal)

        without_admin = SpendingProposal.without_admin

        expect(without_admin.size).to eq(1)
        expect(without_admin.first).to eq(spending_proposal3)
      end
    end

    describe "managed" do
      it "should return all open spending proposals with assigned admin but without assigned valuators" do
        spending_proposal1 = create(:spending_proposal, administrator: create(:administrator))
        spending_proposal2 = create(:spending_proposal, administrator: create(:administrator), valuation_finished: true)
        spending_proposal3 = create(:spending_proposal, administrator: create(:administrator))
        spending_proposal1.valuators << create(:valuator)

        managed = SpendingProposal.managed

        expect(managed.size).to eq(1)
        expect(managed.first).to eq(spending_proposal3)
      end
    end

    describe "valuating" do
      it "should return all spending proposals with assigned valuator but valuation not finished" do
        spending_proposal1 = create(:spending_proposal)
        spending_proposal2 = create(:spending_proposal)
        spending_proposal3 = create(:spending_proposal, valuation_finished: true)

        spending_proposal2.valuators << create(:valuator)
        spending_proposal3.valuators << create(:valuator)

        valuating = SpendingProposal.valuating

        expect(valuating.size).to eq(1)
        expect(valuating.first).to eq(spending_proposal2)
      end
    end

    describe "valuation_finished" do
      it "should return all spending proposals with valuation finished" do
        spending_proposal1 = create(:spending_proposal)
        spending_proposal2 = create(:spending_proposal)
        spending_proposal3 = create(:spending_proposal, valuation_finished: true)

        spending_proposal2.valuators << create(:valuator)
        spending_proposal3.valuators << create(:valuator)

        valuation_finished = SpendingProposal.valuation_finished

        expect(valuation_finished.size).to eq(1)
        expect(valuation_finished.first).to eq(spending_proposal3)
      end
    end
  end

end
