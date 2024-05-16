require "rails_helper"

# TODO: tests were copied; write proper tests
describe Poll::WebVote do
  describe "#save_and_record_voter_participation" do
    let(:author) { create(:user, :level_two) }
    let(:poll) { create(:poll) }
    let(:question) { create(:poll_question, :yes_no, poll: poll) }

    it "creates a poll_voter with user and poll data" do
      answer = create(:poll_answer, question: question, author: author, answer: "Yes")
      expect(answer.poll.voters).to be_blank

      answer.save_and_record_voter_participation
      expect(poll.reload.voters.size).to eq(1)
      voter = poll.voters.first

      expect(voter.document_number).to eq(answer.author.document_number)
      expect(voter.poll_id).to eq(answer.poll.id)
      expect(voter.officer_id).to be nil
    end

    it "updates a poll_voter with user and poll data" do
      answer = create(:poll_answer, question: question, author: author, answer: "Yes")
      answer.save_and_record_voter_participation

      expect(poll.reload.voters.size).to eq(1)

      updated_answer = answer.question.find_or_initialize_user_answer(
        answer.author,
        answer.question.question_options.excluding(answer.option).sample.id
      )
      updated_answer.save_and_record_voter_participation

      expect(poll.reload.voters.size).to eq(1)

      voter = poll.voters.first
      expect(voter.document_number).to eq(updated_answer.author.document_number)
      expect(voter.poll_id).to eq(updated_answer.poll.id)
    end

    it "does not save the answer if the voter is invalid" do
      allow_any_instance_of(Poll::Voter).to receive(:valid?).and_return(false)
      answer = build(:poll_answer)

      expect do
        answer.save_and_record_voter_participation
      end.to raise_error(ActiveRecord::RecordInvalid)

      expect(answer).not_to be_persisted
    end

    it "does not create two voters when creating two answers at the same time", :race_condition do
      answer = build(:poll_answer, question: question, author: author, answer: "Yes")
      other_answer = build(:poll_answer, question: question, author: author, answer: "No")

      [answer, other_answer].map do |poll_answer|
        Thread.new do
          poll_answer.save_and_record_voter_participation
        rescue ActiveRecord::RecordInvalid
        end
      end.each(&:join)

      expect(Poll::Voter.count).to be 1
    end

    it "does not create two voters when calling the method twice at the same time", :race_condition do
      answer = create(:poll_answer, question: question, author: author, answer: "Yes")

      2.times.map do
        Thread.new { answer.save_and_record_voter_participation }
      end.each(&:join)

      expect(Poll::Voter.count).to be 1
    end
  end

  context "creating answers at the same time", :race_condition do
    it "validates max votes on single-answer questions" do
      author = create(:user)
      question = create(:poll_question, :yes_no)

      answer = build(:poll_answer, author: author, question: question, answer: "Yes")
      other_answer = build(:poll_answer, author: author, question: question, answer: "No")

      [answer, other_answer].map do |poll_answer|
        Thread.new { poll_answer.save }
      end.each(&:join)

      expect(Poll::Answer.count).to be 1
    end

    it "validates max votes on multiple-answer questions" do
      author = create(:user, :level_two)
      question = create(:poll_question_multiple, :abc, max_votes: 2)
      create(:poll_answer, question: question, answer: "Answer A", author: author)
      answer = build(:poll_answer, question: question, answer: "Answer B", author: author)
      other_answer = build(:poll_answer, question: question, answer: "Answer C", author: author)

      [answer, other_answer].map do |poll_answer|
        Thread.new { poll_answer.save }
      end.each(&:join)

      expect(Poll::Answer.count).to be 2
    end
  end
end
