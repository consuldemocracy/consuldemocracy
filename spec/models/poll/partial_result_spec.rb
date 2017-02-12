require 'rails_helper'

describe Poll::PartialResult do

  describe "validations" do
    it "validates that the answers are included in the Poll::Question's list" do
      q = create(:poll_question, valid_answers: 'One, Two, Three')
      expect(build(:poll_partial_result, question: q, answer: 'One')).to be_valid
      expect(build(:poll_partial_result, question: q, answer: 'Two')).to be_valid
      expect(build(:poll_partial_result, question: q, answer: 'Three')).to be_valid

      expect(build(:poll_partial_result, question: q, answer: 'Four')).to_not be_valid
    end
  end

  describe "logging changes" do
    it "should update amount_log if amount changes" do
      partial_result = create(:poll_partial_result, amount: 33)

      expect(partial_result.amount_log).to eq("")

      partial_result.amount = 33
      partial_result.save
      partial_result.amount = 32
      partial_result.save
      partial_result.amount = 34
      partial_result.save

      expect(partial_result.amount_log).to eq(":33:32")
    end

    it "should update officer_assignment_id_log if amount changes" do
      partial_result = create(:poll_partial_result, amount: 33)

      expect(partial_result.amount_log).to eq("")
      expect(partial_result.officer_assignment_id_log).to eq("")

      partial_result.amount = 33
      partial_result.officer_assignment = create(:poll_officer_assignment, id: 10)
      partial_result.save

      partial_result.amount = 32
      partial_result.officer_assignment = create(:poll_officer_assignment, id: 20)
      partial_result.save

      partial_result.amount = 34
      partial_result.officer_assignment = create(:poll_officer_assignment, id: 30)
      partial_result.save

      expect(partial_result.amount_log).to eq(":33:32")
      expect(partial_result.officer_assignment_id_log).to eq(":10:20")
    end

    it "should update author_id if amount changes" do
      partial_result = create(:poll_partial_result, amount: 33)

      expect(partial_result.amount_log).to eq("")
      expect(partial_result.author_id_log).to eq("")

      author_A = create(:poll_officer).user
      author_B = create(:poll_officer).user
      author_C = create(:poll_officer).user

      partial_result.amount = 33
      partial_result.author_id = author_A.id
      partial_result.save!

      partial_result.amount = 32
      partial_result.author_id = author_B.id
      partial_result.save!

      partial_result.amount = 34
      partial_result.author_id = author_C.id
      partial_result.save!

      expect(partial_result.amount_log).to eq(":33:32")
      expect(partial_result.author_id_log).to eq(":#{author_A.id}:#{author_B.id}")
    end
  end

end
