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

  it "set correct group and budget ids" do
    budget = create(:budget)
    group_1 = create(:budget_group, budget: budget)
    group_2 = create(:budget_group, budget: budget)

    heading_1 = create(:budget_heading, group: group_1)
    heading_2 = create(:budget_heading, group: group_2)

    investment = create(:budget_investment, heading: heading_1)

    expect(investment.budget_id).to eq budget.id
    expect(investment.group_id).to eq group_1.id

    investment.update(heading: heading_2)

    expect(investment.budget_id).to eq budget.id
    expect(investment.group_id).to eq group_2.id
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
    let(:investment) { create(:budget_investment) }

      it "returns the proposal id" do
        expect(investment.code).to include("#{investment.id}")
      end

      it "returns the administrator id when assigned" do
        investment.administrator = create(:administrator)
        expect(investment.code).to include("#{investment.id}-A#{investment.administrator.id}")
      end
  end

  describe "#send_unfeasible_email" do
    let(:investment) { create(:budget_investment) }

    it "sets the time when the unfeasible email was sent" do
      expect(investment.unfeasible_email_sent_at).to_not be
      investment.send_unfeasible_email
      expect(investment.unfeasible_email_sent_at).to be
    end

    it "send an email" do
      expect {investment.send_unfeasible_email}.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "#should_show_votes?" do
    it "returns true in selecting phase" do
      budget = create(:budget, phase: "selecting")
      investment = create(:budget_investment, budget: budget)

      expect(investment.should_show_votes?).to eq(true)
    end

    it "returns false in any other phase" do
      Budget::PHASES.reject {|phase| phase == "selecting"}.each do |phase|
        budget = create(:budget, phase: phase)
        investment = create(:budget_investment, budget: budget)

        expect(investment.should_show_votes?).to eq(false)
      end
    end
  end

  describe "by_admin" do
    it "should return investments assigned to specific administrator" do
      investment1 = create(:budget_investment, administrator_id: 33)
      create(:budget_investment)

      by_admin = Budget::Investment.by_admin(33)

      expect(by_admin.size).to eq(1)
      expect(by_admin.first).to eq(investment1)
    end
  end

  describe "by_valuator" do
    it "should return investments assigned to specific valuator" do
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
      it "should return all investments with false valuation_finished" do
        investment1 = create(:budget_investment, valuation_finished: true)
        investment2 = create(:budget_investment)

        valuation_open = Budget::Investment.valuation_open

        expect(valuation_open.size).to eq(1)
        expect(valuation_open.first).to eq(investment2)
      end
    end

    describe "without_admin" do
      it "should return all open investments without assigned admin" do
        investment1 = create(:budget_investment, valuation_finished: true)
        investment2 = create(:budget_investment, administrator: create(:administrator))
        investment3 = create(:budget_investment)

        without_admin = Budget::Investment.without_admin

        expect(without_admin.size).to eq(1)
        expect(without_admin.first).to eq(investment3)
      end
    end

    describe "managed" do
      it "should return all open investments with assigned admin but without assigned valuators" do
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
      it "should return all investments with assigned valuator but valuation not finished" do
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
      it "should return all investments with valuation finished" do
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
      it "should return all feasible investments" do
        feasible_investment = create(:budget_investment, :feasible)
        create(:budget_investment)

        expect(Budget::Investment.feasible).to eq [feasible_investment]
      end
    end

    describe "unfeasible" do
      it "should return all unfeasible investments" do
        unfeasible_investment = create(:budget_investment, :unfeasible)
        create(:budget_investment, :feasible)

        expect(Budget::Investment.unfeasible).to eq [unfeasible_investment]
      end
    end
  end

  describe "search" do

    context "tags" do
      it "searches by tags" do
        investment = create(:budget_investment, tag_list: 'Latina')

        results = Budget::Investment.search('Latina')
        expect(results.first).to eq(investment)

        results = Budget::Investment.search('Latin')
        expect(results.first).to eq(investment)
      end
    end

  end


  describe 'Permissions' do
    let(:budget)      { create(:budget) }
    let(:group)       { create(:budget_group, budget: budget) }
    let(:heading)     { create(:budget_heading, group: group) }
    let(:user)        { create(:user, :level_two) }
    let(:luser)       { create(:user) }
    let(:district_sp) { create(:budget_investment, budget: budget, group: group, heading: heading) }

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

      it "rejects votes in two headings of the same group" do
        carabanchel = create(:budget_heading, group: group)
        salamanca   = create(:budget_heading, group: group)

        carabanchel_investment = create(:budget_investment, heading: carabanchel)
        salamanca_investment   = create(:budget_investment, heading: salamanca)

        create(:vote, votable: carabanchel_investment, voter: user)

        expect(salamanca_investment.valid_heading?(user)).to eq(false)
      end

      it "allows votes in a group with a single heading" do
        all_city_investment = create(:budget_investment, heading: heading)
        expect(all_city_investment.valid_heading?(user)).to eq(true)
      end

      it "allows votes in a group with a single heading after voting in that heading" do
        all_city_investment1 = create(:budget_investment, heading: heading)
        all_city_investment2 = create(:budget_investment, heading: heading)

        create(:vote, votable: all_city_investment1, voter: user)

        expect(all_city_investment2.valid_heading?(user)).to eq(true)
      end

      it "allows votes in a group with a single heading after voting in another group" do
        districts = create(:budget_group, budget: budget)
        carabanchel = create(:budget_heading, group: districts)

        all_city_investment    = create(:budget_investment, heading: heading)
        carabanchel_investment = create(:budget_investment, heading: carabanchel)

        create(:vote, votable: carabanchel_investment, voter: user)

        expect(all_city_investment.valid_heading?(user)).to eq(true)
      end

      it "allows votes in a group with multiple headings after voting in group with a single heading" do
        districts = create(:budget_group, budget: budget)
        carabanchel = create(:budget_heading, group: districts)
        salamanca   = create(:budget_heading, group: districts)

        all_city_investment    = create(:budget_investment, heading: heading)
        carabanchel_investment = create(:budget_investment, heading: carabanchel)

        create(:vote, votable: all_city_investment, voter: user)

        expect(carabanchel_investment.valid_heading?(user)).to eq(true)
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
      user.update(document_number: nil)
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
      i = create(:budget_investment, budget: b, group: g, heading: h)

      i.register_selection(create(:user, :level_two))
      expect(i.total_votes).to eq(1)

      i.physical_votes = 10
      expect(i.total_votes).to eq(11)
    end
  end

  describe "#with_supports" do
    it "should return proposals with supports" do
      inv1 = create(:budget_investment)
      inv2 = create(:budget_investment)
      create(:vote, votable: inv1)

      expect(Budget::Investment.with_supports).to include(inv1)
      expect(Budget::Investment.with_supports).to_not include(inv2)
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
      let(:investment)  { create(:budget_investment, :selected, budget: budget, heading: heading) }

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

        it "rejects votes when voting is not allowed (wrong phase)" do
          budget.phase = "reviewing"
          expect(investment.reason_for_not_being_ballotable_by(user, ballot)).to eq(:no_ballots_allowed)
        end

        it "rejects non-selected investments" do
          investment.selected = false
          expect(investment.reason_for_not_being_ballotable_by(user, ballot)).to eq(:not_selected)
        end

        it "accepts valid ballots when voting is allowed" do
          budget.phase = "balloting"
          expect(investment.reason_for_not_being_ballotable_by(user, ballot)).to be_nil
        end

        it "accepts valid selections" do
          budget.phase = "selecting"
          expect(investment.reason_for_not_being_selectable_by(user)).to be_nil
        end

        it "rejects users with different headings" do
          budget.phase = "balloting"
          group = create(:budget_group, budget: budget)
          california = create(:budget_heading, group: group)
          new_york = create(:budget_heading, group: group)

          inv1 = create(:budget_investment, :selected, budget: budget, group: group, heading: california)
          inv2 = create(:budget_investment, :selected, budget: budget, group: group, heading: new_york)
          ballot = create(:budget_ballot, user: user, budget: budget)
          ballot.investments << inv1

          expect(inv2.reason_for_not_being_ballotable_by(user, ballot)).to eq(:different_heading_assigned)
        end

        it "rejects proposals with price higher than current available money" do
          budget.phase = "balloting"
          districts = create(:budget_group, budget: budget)
          carabanchel = create(:budget_heading, group: districts, price: 35)
          inv1 = create(:budget_investment, :selected, budget: budget, group: districts, heading: carabanchel, price: 30)
          inv2 = create(:budget_investment, :selected, budget: budget, group: districts, heading: carabanchel, price: 10)

          ballot = create(:budget_ballot, user: user, budget: budget)
          ballot.investments << inv1

          expect(inv2.reason_for_not_being_ballotable_by(user, ballot)).to eq(:not_enough_money)
        end

      end

    end

  end

end
