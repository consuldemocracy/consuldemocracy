require 'rails_helper'

describe :final_recount do

  let(:final_recount) { build(:poll_final_recount) }

  describe "validations" do

    it "should be valid" do
      expect(final_recount).to be_valid
    end

    context "origin" do
      it "should not be valid without an origin" do
        final_recount.origin = nil
        expect(final_recount).to_not be_valid
      end

      it "should not be valid without a valid origin" do
        final_recount.origin = "invalid_origin"
        expect(final_recount).to_not be_valid
      end

      it "should be valid with a valid origin" do
        final_recount.origin = "web"
        expect(final_recount).to be_valid

        final_recount.origin = "booth"
        expect(final_recount).to be_valid

        final_recount.origin = "letter"
        expect(final_recount).to be_valid
      end
    end

  end

  describe "scopes" do

    describe "#web" do
      it "returns final recounts with a web origin" do

        final_recount1 = create(:poll_final_recount, origin: "web")
        final_recount2 = create(:poll_final_recount, origin: "web")
        final_recount3 = create(:poll_final_recount, origin: "booth")

        web_final_recounts = Poll::TotalResult.where(origin: 'web')

        expect(web_final_recounts.count).to eq(2)
        expect(web_final_recounts).to     include(final_recount1)
        expect(web_final_recounts).to     include(final_recount2)
        expect(web_final_recounts).to_not include(final_recount3)
      end
    end

    describe "#booth" do
      it "returns final recounts with a booth origin" do
        final_recount1 = create(:poll_final_recount, origin: "booth")
        final_recount2 = create(:poll_final_recount, origin: "booth")
        final_recount3 = create(:poll_final_recount, origin: "web")

        booth_final_recounts = Poll::TotalResult.where(origin: 'booth')

        expect(booth_final_recounts.count).to eq(2)
        expect(booth_final_recounts).to     include(final_recount1)
        expect(booth_final_recounts).to     include(final_recount2)
        expect(booth_final_recounts).to_not include(final_recount3)
      end
    end

    describe "#letter" do
      it "returns final recounts with a letter origin" do
        final_recount1 = create(:poll_final_recount, origin: "letter")
        final_recount2 = create(:poll_final_recount, origin: "letter")
        final_recount3 = create(:poll_final_recount, origin: "web")

        letter_final_recounts = Poll::TotalResult.where(origin: 'letter')

        expect(letter_final_recounts.count).to eq(2)
        expect(letter_final_recounts).to     include(final_recount1)
        expect(letter_final_recounts).to     include(final_recount2)
        expect(letter_final_recounts).to_not include(final_recount3)
      end
    end

  end


  it "should update count_log if count changes" do
    final_recount = create(:poll_final_recount, count: 33)

    expect(final_recount.count_log).to eq("")

    final_recount.count = 33
    final_recount.save
    final_recount.count = 32
    final_recount.save
    final_recount.count = 34
    final_recount.save

    expect(final_recount.count_log).to eq(":33:32")
  end

  it "should update officer_assignment_id_log if count changes" do
    final_recount = create(:poll_final_recount, count: 33)

    expect(final_recount.count_log).to eq("")

    final_recount.count = 33
    final_recount.officer_assignment = create(:poll_officer_assignment, id: 111)
    final_recount.save

    final_recount.count = 32
    final_recount.officer_assignment = create(:poll_officer_assignment, id: 112)
    final_recount.save

    final_recount.count = 34
    final_recount.officer_assignment = create(:poll_officer_assignment, id: 113)
    final_recount.save

    expect(final_recount.officer_assignment_id_log).to eq(":111:112")
  end

end
