require 'rails_helper'

describe Poll::NullResult do

  describe "logging changes" do
    it "should update amount_log if amount changes" do
      null_result = create(:poll_null_result, amount: 33)

      expect(null_result.amount_log).to eq("")

      null_result.amount = 33
      null_result.save
      null_result.amount = 32
      null_result.save
      null_result.amount = 34
      null_result.save

      expect(null_result.amount_log).to eq(":33:32")
    end

    it "should update officer_assignment_id_log if amount changes" do
      null_result = create(:poll_null_result, amount: 33)

      expect(null_result.amount_log).to eq("")
      expect(null_result.officer_assignment_id_log).to eq("")

      null_result.amount = 33
      null_result.officer_assignment = create(:poll_officer_assignment, id: 101)
      null_result.save

      null_result.amount = 32
      null_result.officer_assignment = create(:poll_officer_assignment, id: 102)
      null_result.save

      null_result.amount = 34
      null_result.officer_assignment = create(:poll_officer_assignment, id: 103)
      null_result.save

      expect(null_result.amount_log).to eq(":33:32")
      expect(null_result.officer_assignment_id_log).to eq(":101:102")
    end

    it "should update author_id if amount changes" do
      null_result = create(:poll_null_result, amount: 33)

      expect(null_result.amount_log).to eq("")
      expect(null_result.author_id_log).to eq("")

      author_A = create(:poll_officer).user
      author_B = create(:poll_officer).user
      author_C = create(:poll_officer).user

      null_result.amount = 33
      null_result.author_id = author_A.id
      null_result.save!

      null_result.amount = 32
      null_result.author_id = author_B.id
      null_result.save!

      null_result.amount = 34
      null_result.author_id = author_C.id
      null_result.save!

      expect(null_result.amount_log).to eq(":33:32")
      expect(null_result.author_id_log).to eq(":#{author_A.id}:#{author_B.id}")
    end
  end

end