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

        expect(ballot_line).to_not be_valid
      end

      it "should not be valid if insufficient funds (district-wide)" do
        geozone = create(:geozone)
        sp = create(:spending_proposal, price: 25000000, geozone: geozone)

        ballot = create(:ballot, geozone: geozone)
        ballot_line = build(:ballot_line, ballot: ballot, spending_proposal: sp)

        expect(ballot_line).to_not be_valid
      end

      it "should be valid if sufficient funds (city-wide)" do
        sp = create(:spending_proposal, price: 23000000)
        ballot_line = build(:ballot_line, spending_proposal: sp)

        expect(ballot_line).to be_valid
      end

      it "should be valid if sufficient funds (district-wide)" do
        geozone = create(:geozone)
        sp = create(:spending_proposal, price: 23000000, geozone: geozone)

        ballot = create(:ballot, geozone: geozone)
        ballot_line = build(:ballot_line, ballot: ballot, spending_proposal: sp)

        expect(ballot_line).to be_valid
      end

    end

    describe 'Geozone' do

      it "should not be valid for a different geozone" do
        california = create(:geozone)
        new_york = create(:geozone)

        sp = create(:spending_proposal, geozone: california)

        ballot = create(:ballot, geozone: new_york)
        ballot_line = build(:ballot_line, ballot: ballot, spending_proposal: sp)

        expect(ballot_line).to_not be_valid
      end

      it "should be valid for the the right geozone" do
        california = create(:geozone)

        sp = create(:spending_proposal, geozone: california)

        ballot = create(:ballot, geozone: california)
        ballot_line = build(:ballot_line, ballot: ballot, spending_proposal: sp)

        expect(ballot_line).to be_valid
      end

    end
  end
end
