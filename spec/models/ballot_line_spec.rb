require 'rails_helper'

describe BallotLine do

  let(:ballot_line) { build(:ballot_line) }

  describe 'Validations' do

    it "should be valid" do
      expect(ballot_line).to be_valid
    end

    describe 'Money' do

      it "should not be valid if insufficient funds (city-wide)" do
        sp = create(:spending_proposal, price: 25000000)
        ballot_line = build(:ballot_line, spending_proposal: sp)

        expect(ballot_line).not_to be_valid
      end

      it "should not be valid if insufficient funds (district-wide)" do
        geozone = create(:geozone, name: "Carabanchel")
        sp = create(:spending_proposal, price: 25000000, geozone: geozone)

        ballot = create(:ballot, geozone: geozone)
        ballot_line = build(:ballot_line, ballot: ballot, spending_proposal: sp)

        expect(ballot_line).not_to be_valid
      end

      it "should be valid if sufficient funds (city-wide)" do
        sp = create(:spending_proposal, :feasible, price: 23000000)
        ballot_line = build(:ballot_line, spending_proposal: sp)

        expect(ballot_line).to be_valid
      end

      it "should be valid if sufficient funds (district-wide)" do
        geozone = create(:geozone, name: "Carabanchel")
        sp = create(:spending_proposal, :feasible, price: 3000000, geozone: geozone)

        ballot = create(:ballot, geozone: geozone)
        ballot_line = build(:ballot_line, ballot: ballot, spending_proposal: sp)

        expect(ballot_line).to be_valid
      end

      it "should be valid if sufficient funds city-wide but insufficient funds district-wide" do
        geozone = create(:geozone, name: "Carabanchel")
        sp1 = create(:spending_proposal, :feasible, price: 3000000, geozone: geozone)
        sp2 = create(:spending_proposal, :feasible, price: 3000000, geozone: nil)

        ballot = create(:ballot, geozone: geozone, spending_proposals: [sp1])

        ballot_line = build(:ballot_line, ballot: ballot, spending_proposal: sp2)

        expect(ballot_line).to be_valid
      end

      it "should be valid if sufficient funds district-wide but insufficient funds city-wide" do
        geozone = create(:geozone, name: "Carabanchel")
        sp1 = create(:spending_proposal, :feasible, price: 23000000, geozone: nil)
        sp2 = create(:spending_proposal, :feasible, price: 3000000,  geozone: geozone)

        ballot = create(:ballot, geozone: geozone, spending_proposals: [sp1])

        ballot_line = build(:ballot_line, ballot: ballot, spending_proposal: sp2)

        expect(ballot_line).to be_valid
      end

    end

    describe 'Geozone' do

      it "should not be valid for a different geozone" do
        geozone1 = create(:geozone, name: "Carabanchel")
        geozone2 = create(:geozone, name: "Centro")

        sp = create(:spending_proposal, geozone: geozone1)

        ballot = create(:ballot, geozone: geozone2)
        ballot_line = build(:ballot_line, ballot: ballot, spending_proposal: sp)

        expect(ballot_line).not_to be_valid
      end

      it "should be valid for the the right geozone" do
        geozone = create(:geozone, name: "Carabanchel")

        sp = create(:spending_proposal, :feasible, geozone: geozone)

        ballot = create(:ballot, geozone: geozone)
        ballot_line = build(:ballot_line, ballot: ballot, spending_proposal: sp)

        expect(ballot_line).to be_valid
      end

      it "should be valid for city-wide proposals" do
        sp = create(:spending_proposal, :feasible, geozone: nil)

        ballot = create(:ballot, geozone: nil)
        ballot_line = build(:ballot_line, ballot: ballot, spending_proposal: sp)

        expect(ballot_line).to be_valid
      end

      it "should be valid for city-wide proposals (when district is set)" do
        geozone = create(:geozone, name: "Carabanchel")

        sp1 = create(:spending_proposal, :feasible, geozone: geozone)
        sp2 = create(:spending_proposal, :feasible, geozone: nil)

        ballot = create(:ballot, geozone: geozone, spending_proposals: [sp1])

        ballot_line = build(:ballot_line, ballot: ballot, spending_proposal: sp2)

        expect(ballot_line).to be_valid
      end

    end

    describe 'Feasibility' do

      it "should not be valid if spending proposal is unfeasible" do
        sp = create(:spending_proposal, price: 20000, feasible: false)
        ballot_line = build(:ballot_line, spending_proposal: sp)

        expect(ballot_line).not_to be_valid
      end

      it "should not be valid if spending proposal feasibility is undecided" do
        sp = create(:spending_proposal, price: 20000, feasible: nil)
        ballot_line = build(:ballot_line, spending_proposal: sp)

        expect(ballot_line).not_to be_valid
      end

      it "should be valid if spending proposal is feasible" do
        sp = create(:spending_proposal, price: 20000, feasible: true)
        ballot_line = build(:ballot_line, spending_proposal: sp)

        expect(ballot_line).to be_valid
      end

    end

  end
end
