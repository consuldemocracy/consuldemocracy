require 'rails_helper'

describe Budget::Investment do
  let(:investment) { build(:budget_investment) }

  it "should be valid" do
    expect(investment).to be_valid
  end

  it "should not be valid without an author" do
    investment.author = nil
    expect(investment).to_not be_valid
  end

  describe "#title" do
    it "should not be valid without a title" do
      investment.title = nil
      expect(investment).to_not be_valid
    end

    it "should not be valid when very short" do
      investment.title = "abc"
      expect(investment).to_not be_valid
    end

    it "should not be valid when very long" do
      investment.title = "a" * 81
      expect(investment).to_not be_valid
    end
  end

  it "sanitizes description" do
    investment.description = "<script>alert('danger');</script>"
    investment.valid?
    expect(investment.description).to eq("alert('danger');")
  end

  describe "#unfeasibility_explanation" do
    it "should be valid if valuation not finished" do
      investment.unfeasibility_explanation = ""
      investment.valuation_finished = false
      expect(investment).to be_valid
    end

    it "should be valid if valuation finished and feasible" do
      investment.unfeasibility_explanation = ""
      investment.feasibility = "feasible"
      investment.valuation_finished = true
      expect(investment).to be_valid
    end

    it "should not be valid if valuation finished and unfeasible" do
      investment.unfeasibility_explanation = ""
      investment.feasibility = "unfeasible"
      investment.valuation_finished = true
      expect(investment).to_not be_valid
    end
  end

  describe "#code" do
    it "returns the investment and budget id" do
      investment = create(:budget_investment)
      expect(investment.code).to include("#{investment.id}")
      expect(investment.code).to include("#{investment.budget.id}")
    end
  end

  describe "by_admin" do
    it "should return spending investments assigned to specific administrator" do
      investment1 = create(:budget_investment, administrator_id: 33)
      create(:budget_investment)

      by_admin = Budget::Investment.by_admin(33)

      expect(by_admin.size).to eq(1)
      expect(by_admin.first).to eq(investment1)
    end
  end

  describe "by_valuator" do
    it "should return spending proposals assigned to specific valuator" do
      investment1 = create(:budget_investment)
      investment2 = create(:budget_investment)
      investment3 = create(:budget_investment)

      valuator1 = create(:valuator)
      valuator2 = create(:valuator)

      investment1.valuators << valuator1
      investment2.valuators << valuator2
      investment3.valuators << [valuator1, valuator2]

      by_valuator = Budget::Investment.by_valuator(valuator1.id)

      expect(by_valuator.size).to eq(2)
      expect(by_valuator.sort).to eq([investment1,investment3].sort)
    end
  end

  describe "scopes" do
    describe "valuation_open" do
      it "should return all spending proposals with false valuation_finished" do
        investment1 = create(:budget_investment, valuation_finished: true)
        investment2 = create(:budget_investment)

        valuation_open = Budget::Investment.valuation_open

        expect(valuation_open.size).to eq(1)
        expect(valuation_open.first).to eq(investment2)
      end
    end

    describe "without_admin" do
      it "should return all open spending proposals without assigned admin" do
        investment1 = create(:budget_investment, valuation_finished: true)
        investment2 = create(:budget_investment, administrator: create(:administrator))
        investment3 = create(:budget_investment)

        without_admin = Budget::Investment.without_admin

        expect(without_admin.size).to eq(1)
        expect(without_admin.first).to eq(investment3)
      end
    end

    describe "managed" do
      it "should return all open spending proposals with assigned admin but without assigned valuators" do
        investment1 = create(:budget_investment, administrator: create(:administrator))
        investment2 = create(:budget_investment, administrator: create(:administrator), valuation_finished: true)
        investment3 = create(:budget_investment, administrator: create(:administrator))
        investment1.valuators << create(:valuator)

        managed = Budget::Investment.managed

        expect(managed.size).to eq(1)
        expect(managed.first).to eq(investment3)
      end
    end

    describe "valuating" do
      it "should return all spending proposals with assigned valuator but valuation not finished" do
        investment1 = create(:budget_investment)
        investment2 = create(:budget_investment)
        investment3 = create(:budget_investment, valuation_finished: true)

        investment2.valuators << create(:valuator)
        investment3.valuators << create(:valuator)

        valuating = Budget::Investment.valuating

        expect(valuating.size).to eq(1)
        expect(valuating.first).to eq(investment2)
      end
    end

    describe "valuation_finished" do
      it "should return all spending proposals with valuation finished" do
        investment1 = create(:budget_investment)
        investment2 = create(:budget_investment)
        investment3 = create(:budget_investment, valuation_finished: true)

        investment2.valuators << create(:valuator)
        investment3.valuators << create(:valuator)

        valuation_finished = Budget::Investment.valuation_finished

        expect(valuation_finished.size).to eq(1)
        expect(valuation_finished.first).to eq(investment3)
      end
    end

    describe "feasible" do
      it "should return all feasible spending proposals" do
        feasible_investment = create(:budget_investment, :feasible)
        create(:budget_investment)

        expect(Budget::Investment.feasible).to eq [feasible_investment]
      end
    end

    describe "unfeasible" do
      it "should return all unfeasible spending proposals" do
        unfeasible_investment = create(:budget_investment, :unfeasible)
        create(:budget_investment, :feasible)

        expect(Budget::Investment.unfeasible).to eq [unfeasible_investment]
      end
    end
  end

  describe 'Permissions' do
    let(:budget)      { create(:budget) }
    let(:group)       { create(:budget_group, budget: budget) }
    let(:heading)     { create(:budget_heading, group: group) }
    let(:user)        { create(:user, :level_two) }
    let(:luser)       { create(:user) }
    let(:district_sp) { create(:budget_investment, heading: heading) }

    describe '#reason_for_not_being_selectable_by' do
      it "rejects not logged in users" do
        expect(district_sp.reason_for_not_being_selectable_by(nil)).to eq(:not_logged_in)
      end

      it "rejects not verified users" do
        expect(district_sp.reason_for_not_being_selectable_by(luser)).to eq(:not_verified)
      end

      it "rejects organizations" do
        create(:organization, user: user)
        expect(district_sp.reason_for_not_being_selectable_by(user)).to eq(:organization)
      end

      it "rejects selections when selecting is not allowed (via admin setting)" do
        budget.phase = "on_hold"
        expect(district_sp.reason_for_not_being_selectable_by(user)).to eq(:no_selecting_allowed)
      end

      it "accepts valid selections when selecting is allowed" do
        budget.phase = "selecting"
        expect(district_sp.reason_for_not_being_selectable_by(user)).to be_nil
      end
    end
  end

  describe "Order" do
    describe "#sort_by_confidence_score" do

      it "should order by confidence_score" do
        least_voted = create(:budget_investment, cached_votes_up: 1)
        most_voted = create(:budget_investment, cached_votes_up: 10)
        some_votes = create(:budget_investment, cached_votes_up: 5)

        expect(Budget::Investment.sort_by_confidence_score.first).to eq most_voted
        expect(Budget::Investment.sort_by_confidence_score.second).to eq some_votes
        expect(Budget::Investment.sort_by_confidence_score.third).to eq least_voted
      end

      it "should order by confidence_score and then by id" do
        least_voted  = create(:budget_investment, cached_votes_up: 1)
        most_voted   = create(:budget_investment, cached_votes_up: 10)
        most_voted2  = create(:budget_investment, cached_votes_up: 10)
        least_voted2 = create(:budget_investment, cached_votes_up: 1)


        expect(Budget::Investment.sort_by_confidence_score.first).to  eq most_voted2
        expect(Budget::Investment.sort_by_confidence_score.second).to  eq most_voted
        expect(Budget::Investment.sort_by_confidence_score.third).to  eq least_voted2
        expect(Budget::Investment.sort_by_confidence_score.fourth).to  eq least_voted
      end
    end
  end

  describe "responsible_name" do
    let(:user) { create(:user, document_number: "123456") }
    let!(:investment) { create(:budget_investment, author: user) }

    it "gets updated with the document_number" do
      expect(investment.responsible_name).to eq("123456")
    end

    it "does not get updated if the user is erased" do
      user.erase
      expect(user.document_number).to be_blank
      investment.touch
      expect(investment.responsible_name).to eq("123456")
    end
  end

  describe "total votes" do
    it "takes into account physical votes in addition to web votes" do
      b = create(:budget, :selecting)
      g = create(:budget_group, budget: b)
      h = create(:budget_heading, group: g)
      sp = create(:budget_investment, heading: h)

      sp.register_selection(create(:user, :level_two))
      expect(sp.total_votes).to eq(1)

      sp.physical_votes = 10
      expect(sp.total_votes).to eq(11)
    end
  end

  describe "#with_supports" do
    it "should return proposals with supports" do
      sp1 = create(:budget_investment)
      sp2 = create(:budget_investment)
      create(:vote, votable: sp1)

      expect(Budget::Investment.with_supports).to include(sp1)
      expect(Budget::Investment.with_supports).to_not include(sp2)
    end
  end

  describe "Final Voting" do

    describe 'Permissions' do
      let(:budget)      { create(:budget) }
      let(:group)       { create(:budget_group, budget: budget) }
      let(:heading)     { create(:budget_heading, group: group) }
      let(:user)        { create(:user, :level_two) }
      let(:luser)       { create(:user) }
      let(:ballot)      { create(:budget_ballot, budget: budget) }
      let(:investment)  { create(:budget_investment, heading: heading) }

      describe '#reason_for_not_being_ballotable_by' do
        it "rejects not logged in users" do
          expect(investment.reason_for_not_being_ballotable_by(nil, ballot)).to eq(:not_logged_in)
        end

        it "rejects not verified users" do
          expect(investment.reason_for_not_being_ballotable_by(luser, ballot)).to eq(:not_verified)
        end

        it "rejects organizations" do
          create(:organization, user: user)
          expect(investment.reason_for_not_being_ballotable_by(user, ballot)).to eq(:organization)
        end

        it "rejects votes when voting is not allowed (via admin setting)" do
          budget.phase = "on_hold"
          expect(investment.reason_for_not_being_ballotable_by(user, ballot)).to eq(:no_ballots_allowed)
        end

        it "accepts valid ballots when voting is allowed" do
          budget.phase = "balloting"
          expect(investment.reason_for_not_being_ballotable_by(user, ballot)).to be_nil
        end

        it "accepts valid district selections" do
          budget.phase = "selecting"
          expect(investment.reason_for_not_being_selectable_by(user)).to be_nil
          ballot.heading_id = heading.id
          expect(investment.reason_for_not_being_selectable_by(user)).to be_nil
        end

        it "rejects users with different headings" do
          budget.phase = "balloting"
          group = create(:budget_group, budget: budget)
          california = create(:budget_heading, group: group)
          new_york = create(:budget_heading, group: group)

          sp1 = create(:budget_investment, :feasible, heading: california)
          sp2 = create(:budget_investment, :feasible, heading: new_york)
          b = create(:budget_ballot, user: user, heading: california, investments: [sp1])

          expect(sp2.reason_for_not_being_ballotable_by(user, b)).to eq(:different_heading_assigned)
        end

        it "rejects proposals with price higher than current available money" do
          budget.phase = "balloting"
          distritos = create(:budget_group, budget: budget)
          carabanchel = create(:budget_heading, group: distritos, price: 35)
          sp1 = create(:budget_investment, :feasible, heading: carabanchel, price: 30)
          sp2 = create(:budget_investment, :feasible, heading: carabanchel, price: 10)
          ballot = create(:budget_ballot, user: user, heading: carabanchel, investments: [sp1])

          expect(sp2.reason_for_not_being_ballotable_by(user, ballot)).to eq(:not_enough_money)
        end

      end

    end

  end

end
