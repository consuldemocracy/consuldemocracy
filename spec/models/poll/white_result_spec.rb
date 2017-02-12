require 'rails_helper'

describe Poll::WhiteResult do

  describe "logging changes" do
    it "should update amount_log if amount changes" do
      white_result = create(:poll_white_result, amount: 33)

      expect(white_result.amount_log).to eq("")

      white_result.amount = 33
      white_result.save
      white_result.amount = 32
      white_result.save
      white_result.amount = 34
      white_result.save

      expect(white_result.amount_log).to eq(":33:32")
    end

    it "should update officer_assignment_id_log if amount changes" do
      white_result = create(:poll_white_result, amount: 33)

      expect(white_result.amount_log).to eq("")
      expect(white_result.officer_assignment_id_log).to eq("")

      white_result.amount = 33
      white_result.officer_assignment = create(:poll_officer_assignment, id: 21)
      white_result.save

      white_result.amount = 32
      white_result.officer_assignment = create(:poll_officer_assignment, id: 22)
      white_result.save

      white_result.amount = 34
      white_result.officer_assignment = create(:poll_officer_assignment, id: 23)
      white_result.save

      expect(white_result.amount_log).to eq(":33:32")
      expect(white_result.officer_assignment_id_log).to eq(":21:22")
    end

    it "should update author_id if amount changes" do
      white_result = create(:poll_white_result, amount: 33)

      expect(white_result.amount_log).to eq("")
      expect(white_result.author_id_log).to eq("")

      author_A = create(:poll_officer).user
      author_B = create(:poll_officer).user
      author_C = create(:poll_officer).user

      white_result.amount = 33
      white_result.author_id = author_A.id
      white_result.save!

      white_result.amount = 32
      white_result.author_id = author_B.id
      white_result.save!

      white_result.amount = 34
      white_result.author_id = author_C.id
      white_result.save!

      expect(white_result.amount_log).to eq(":33:32")
      expect(white_result.author_id_log).to eq(":#{author_A.id}:#{author_B.id}")
    end
  end

end