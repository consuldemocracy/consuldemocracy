require 'rails_helper'

describe Poll::TotalResult do

  describe "logging changes" do
    it "should update amount_log if amount changes" do
      total_result = create(:poll_total_result, amount: 33)

      expect(total_result.amount_log).to eq("")

      total_result.amount = 33
      total_result.save
      total_result.amount = 32
      total_result.save
      total_result.amount = 34
      total_result.save

      expect(total_result.amount_log).to eq(":33:32")
    end

    it "should update officer_assignment_id_log if amount changes" do
      total_result = create(:poll_total_result, amount: 33)

      expect(total_result.amount_log).to eq("")
      expect(total_result.officer_assignment_id_log).to eq("")

      total_result.amount = 33
      total_result.officer_assignment = create(:poll_officer_assignment, id: 101)
      total_result.save

      total_result.amount = 32
      total_result.officer_assignment = create(:poll_officer_assignment, id: 102)
      total_result.save

      total_result.amount = 34
      total_result.officer_assignment = create(:poll_officer_assignment, id: 103)
      total_result.save

      expect(total_result.amount_log).to eq(":33:32")
      expect(total_result.officer_assignment_id_log).to eq(":101:102")
    end

    it "should update author_id if amount changes" do
      total_result = create(:poll_total_result, amount: 33)

      expect(total_result.amount_log).to eq("")
      expect(total_result.author_id_log).to eq("")

      author_A = create(:poll_officer).user
      author_B = create(:poll_officer).user
      author_C = create(:poll_officer).user

      total_result.amount = 33
      total_result.author_id = author_A.id
      total_result.save!

      total_result.amount = 32
      total_result.author_id = author_B.id
      total_result.save!

      total_result.amount = 34
      total_result.author_id = author_C.id
      total_result.save!

      expect(total_result.amount_log).to eq(":33:32")
      expect(total_result.author_id_log).to eq(":#{author_A.id}:#{author_B.id}")
    end
  end

end
