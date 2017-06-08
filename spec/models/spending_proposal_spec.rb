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

  describe "#feasible_explanation" do
    it "should be valid if valuation not finished" do
      spending_proposal.feasible_explanation = ""
      spending_proposal.valuation_finished = false
      expect(spending_proposal).to be_valid
    end

    it "should be valid if valuation finished and feasible" do
      spending_proposal.feasible_explanation = ""
      spending_proposal.feasible = true
      spending_proposal.valuation_finished = true
      expect(spending_proposal).to be_valid
    end

    it "should not be valid if valuation finished and unfeasible" do
      spending_proposal.feasible_explanation = ""
      spending_proposal.feasible = false
      spending_proposal.valuation_finished = true
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

    describe "#unfeasible_email_pending?" do
      let(:spending_proposal) { create(:spending_proposal) }

      it "returns true when marked as unfeasibable and valuation_finished" do
        spending_proposal.update(feasible: false, valuation_finished: true)
        expect(spending_proposal.unfeasible_email_pending?).to eq true
      end

      it "returns false when marked as feasible" do
        spending_proposal.update(feasible: true)
        expect(spending_proposal.unfeasible_email_pending?).to eq false
      end

      it "returns false when marked as feasable and valuation_finished" do
        spending_proposal.update(feasible: true, valuation_finished: true)
        expect(spending_proposal.unfeasible_email_pending?).to eq false
      end

      it "returns false when unfeasible email already sent" do
        spending_proposal.update(unfeasible_email_sent_at: 1.day.ago)
        expect(spending_proposal.unfeasible_email_pending?).to eq false
      end
    end

    describe "#send_unfeasible_email" do
      let(:spending_proposal) { create(:spending_proposal) }

      it "sets the time when the unfeasible email was sent" do
        expect(spending_proposal.unfeasible_email_sent_at).to_not be
        spending_proposal.send_unfeasible_email
        expect(spending_proposal.unfeasible_email_sent_at).to be
      end

      it "send an email" do
        expect {spending_proposal.send_unfeasible_email}.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    describe "#code" do
      let(:spending_proposal) { create(:spending_proposal) }

      it "returns the proposal id" do
        expect(spending_proposal.code).to include("#{spending_proposal.id}")
      end

      it "returns the administrator id when assigned" do
        spending_proposal.administrator = create(:administrator)
        expect(spending_proposal.code).to include("#{spending_proposal.id}-A#{spending_proposal.administrator.id}")
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
      expect(by_valuator.sort).to eq([spending_proposal1, spending_proposal3].sort)
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

    describe "feasible" do
      it "should return all feasible spending proposals" do
        feasible_spending_proposal = create(:spending_proposal, feasible: true)
        create(:spending_proposal)

        expect(SpendingProposal.feasible).to eq [feasible_spending_proposal]
      end
    end

    describe "unfeasible" do
      it "should return all unfeasible spending proposals" do
        unfeasible_spending_proposal = create(:spending_proposal, feasible: false)
        create(:spending_proposal, feasible: true)

        expect(SpendingProposal.unfeasible).to eq [unfeasible_spending_proposal]
      end
    end

    describe "not_unfeasible" do
      it "should return all not unfeasible spending proposals" do
        not_unfeasible_spending_proposal_1 = create(:spending_proposal, feasible: true)
        not_unfeasible_spending_proposal_2 = create(:spending_proposal)
        create(:spending_proposal, feasible: false)

        not_unfeasibles = SpendingProposal.not_unfeasible

        expect(not_unfeasibles.size).to eq(2)
        expect(not_unfeasibles.include?(not_unfeasible_spending_proposal_1)).to eq(true)
        expect(not_unfeasibles.include?(not_unfeasible_spending_proposal_2)).to eq(true)
      end
    end
  end

  describe 'Supports' do
    let(:user)        { create(:user, :level_two) }
    let(:luser)       { create(:user) }
    let(:district)    { create(:geozone) }
    let(:city_sp)     { create(:spending_proposal) }
    let(:district_sp) { create(:spending_proposal, geozone: district) }

    before do
      Setting["feature.spending_proposals"] = true
      Setting['feature.spending_proposal_features.voting_allowed'] = true
    end

    after do
      Setting["feature.spending_proposals"] = nil
      Setting['feature.spending_proposal_features.voting_allowed'] = nil
    end

    describe '#reason_for_not_being_votable_by' do
      it "rejects not logged in users" do
        expect(city_sp.reason_for_not_being_votable_by(nil)).to eq(:not_logged_in)
        expect(district_sp.reason_for_not_being_votable_by(nil)).to eq(:not_logged_in)
      end

      it "rejects not verified users" do
        expect(city_sp.reason_for_not_being_votable_by(luser)).to eq(:not_verified)
        expect(district_sp.reason_for_not_being_votable_by(luser)).to eq(:not_verified)
      end

      it "rejects unfeasible spending proposals" do
        unfeasible = create(:spending_proposal, feasible: false, valuation_finished: true)
        expect(unfeasible.reason_for_not_being_votable_by(user)).to eq(:unfeasible)
      end

      it "rejects organizations" do
        create(:organization, user: user)
        expect(city_sp.reason_for_not_being_votable_by(user)).to eq(:organization)
        expect(district_sp.reason_for_not_being_votable_by(user)).to eq(:organization)
      end

      it "rejects votes when voting is not allowed (via admin setting)" do
        Setting["feature.spending_proposal_features.voting_allowed"] = nil
        expect(city_sp.reason_for_not_being_votable_by(user)).to eq(:not_voting_allowed)
        expect(district_sp.reason_for_not_being_votable_by(user)).to eq(:not_voting_allowed)
      end

      it "accepts valid votes when voting is allowed" do
        Setting["feature.spending_proposal_features.voting_allowed"] = true
        expect(city_sp.reason_for_not_being_votable_by(user)).to be_nil
        expect(district_sp.reason_for_not_being_votable_by(user)).to be_nil

        Setting["feature.spending_proposal_features.voting_allowed"] = nil
      end
    end
  end

  describe "responsible_name" do
    let(:user) { create(:user, document_number: "123456") }
    let!(:spending_proposal) { create(:spending_proposal, author: user) }

    it "gets updated with the document_number" do
      expect(spending_proposal.responsible_name).to eq("123456")
    end

    it "does not get updated if the user is erased" do
      user.erase
      expect(user.erased_at).to be
      spending_proposal.touch
      expect(spending_proposal.responsible_name).to eq("123456")
    end
  end

  describe "total votes" do
    before do
      Setting["feature.spending_proposals"] = true
      Setting['feature.spending_proposal_features.voting_allowed'] = true
    end

    after do
      Setting["feature.spending_proposals"] = nil
      Setting['feature.spending_proposal_features.voting_allowed'] = nil
    end

    it "takes into account physical votes in addition to web votes" do

      sp = create(:spending_proposal)
      sp.register_vote(create(:user, :level_two), true)
      expect(sp.total_votes).to eq(1)
      sp.physical_votes = 10
      expect(sp.total_votes).to eq(11)
    end
  end

  describe "#with_supports" do
    it "should return proposals with supports" do
      sp1 = create(:spending_proposal)
      sp2 = create(:spending_proposal)
      create(:vote, votable: sp1)

      expect(SpendingProposal.with_supports).to include(sp1)
      expect(SpendingProposal.with_supports).to_not include(sp2)
    end
  end

end
