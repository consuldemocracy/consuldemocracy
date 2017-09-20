require 'rails_helper'

describe Poll::Recount do

  describe "logging changes" do
    it "should update amount_log if amount changes" do
      recount = create(:poll_recount, amount: 33)

      expect(recount.amount_log).to eq("")

      recount.amount = 33
      recount.save
      recount.amount = 32
      recount.save
      recount.amount = 34
      recount.save

      expect(recount.amount_log).to eq(":33:32")
    end

    it "should update officer_assignment_id_log if amount changes" do
      recount = create(:poll_recount, amount: 33)

      expect(recount.amount_log).to eq("")
      expect(recount.officer_assignment_id_log).to eq("")

      recount.amount = 33
      recount.officer_assignment = create(:poll_officer_assignment, id: 101)
      recount.save

      recount.amount = 32
      recount.officer_assignment = create(:poll_officer_assignment, id: 102)
      recount.save

      recount.amount = 34
      recount.officer_assignment = create(:poll_officer_assignment, id: 103)
      recount.save

      expect(recount.amount_log).to eq(":33:32")
      expect(recount.officer_assignment_id_log).to eq(":101:102")
    end

    it "should update author_id if amount changes" do
      recount = create(:poll_recount, amount: 33)

      expect(recount.amount_log).to eq("")
      expect(recount.author_id_log).to eq("")

      author_A = create(:poll_officer).user
      author_B = create(:poll_officer).user
      author_C = create(:poll_officer).user

      recount.amount = 33
      recount.author_id = author_A.id
      recount.save!

      recount.amount = 32
      recount.author_id = author_B.id
      recount.save!

      recount.amount = 34
      recount.author_id = author_C.id
      recount.save!

      expect(recount.amount_log).to eq(":33:32")
      expect(recount.author_id_log).to eq(":#{author_A.id}:#{author_B.id}")
    end
  end

end
