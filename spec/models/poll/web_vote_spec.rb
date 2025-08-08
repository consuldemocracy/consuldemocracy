require "rails_helper"

describe Poll::WebVote do
  describe "#update" do
    let(:user) { create(:user, :level_two) }
    let(:poll) { create(:poll) }
    let!(:question) { create(:poll_question, :yes_no, poll: poll) }
    let(:option_yes) { question.question_options.find_by(title: "Yes") }
    let(:option_no) { question.question_options.find_by(title: "No") }
    let(:web_vote) { Poll::WebVote.new(poll, user) }

    it "creates a poll_voter with user and poll data" do
      expect(poll.voters).to be_blank
      expect(question.answers).to be_blank

      web_vote.update(question.id.to_s => { option_id: option_yes.id.to_s })

      expect(poll.reload.voters.size).to eq 1
      expect(question.reload.answers.size).to eq 1

      voter = poll.voters.first
      answer = question.answers.first

      expect(answer.author).to eq user
      expect(voter.document_number).to eq user.document_number
      expect(voter.poll_id).to eq answer.poll.id
      expect(voter.officer_id).to be nil
    end

    it "updates a poll_voter with user and poll data" do
      answer = create(:poll_answer, question: question, author: user, option: option_yes)

      web_vote.update(question.id.to_s => { option_id: option_no.id.to_s })

      expect(poll.reload.voters.size).to eq 1
      expect(question.reload.answers.size).to eq 1
      expect(question.answers.first).to eq answer.reload

      voter = poll.voters.first

      expect(answer.author).to eq user
      expect(answer.option).to eq option_no
      expect(voter.document_number).to eq answer.author.document_number
      expect(voter.poll_id).to eq answer.poll.id
    end

    it "updates existing multiple options instead of adding new ones" do
      question = create(:poll_question_multiple, :abc, poll: poll, max_votes: 2)
      option_a = question.question_options.find_by(title: "Answer A")
      option_b = question.question_options.find_by(title: "Answer B")
      option_c = question.question_options.find_by(title: "Answer C")

      create(:poll_answer, author: user, question: question, option: option_a)
      create(:poll_answer, author: user, question: question, option: option_b)

      web_vote.update(question.id.to_s => { option_id: [option_c.id.to_s] })

      expect(question.reload.answers.size).to eq 1
      expect(question.reload.answers.first.option).to eq option_c
    end

    it "does not save the answer if the voter is invalid" do
      allow_any_instance_of(Poll::Voter).to receive(:valid?).and_return(false)

      expect do
        web_vote.update(question.id.to_s => { option_id: option_yes.id.to_s })
      end.to raise_error(ActiveRecord::RecordInvalid)

      expect(poll.voters).to be_blank
      expect(question.answers).to be_blank
    end

    it "does not save the answer if it exceeds the allowed max votes" do
      question = create(:poll_question_multiple, :abc, poll: poll, max_votes: 2)

      result = web_vote.update(question.id.to_s => { option_id: question.question_options.ids.map(&:to_s) })

      expect(result).to be false
      expect(poll.voters).to be_blank
      expect(question.answers).to be_blank
    end

    it "does not save the answer if unique question receives multiple options" do
      question = create(:poll_question, :yes_no, poll: poll)

      result = web_vote.update(
        question.id.to_s => { option_id: question.question_options.ids.map(&:to_s) }
      )

      expect(result).to be false
      expect(poll.voters).to be_blank
      expect(question.answers).to be_blank
    end

    it "creates a voter but does not create answers when leaving everything blank" do
      web_vote.update({})

      expect(poll.reload.voters.size).to eq 1
      expect(question.reload.answers.size).to eq 0
    end

    it "deletes existing answers but keeps voters when no answers are given" do
      create(:poll_answer, question: question, author: user, option: option_yes)
      create(:poll_voter, poll: poll, user: user)

      web_vote.update({})

      expect(poll.reload.voters.size).to eq 1
      expect(poll.voters.first.user).to eq user
      expect(question.reload.answers.size).to eq 0
    end

    it "raises an exception when the user has already voted in a booth" do
      create(:poll_voter, :from_booth, poll: poll, user: user)

      expect do
        web_vote.update(question.id.to_s => { option_id: option_yes.id.to_s })
      end.to raise_error(ActiveRecord::RecordNotFound)

      expect(poll.reload.voters.size).to eq 1
      expect(poll.voters.first.user).to eq user
      expect(question.reload.answers.size).to eq 0
    end

    context "creating answers at the same time", :race_condition do
      it "does not create two voters or two answers for two different answers" do
        [option_yes, option_no].map do |option|
          Thread.new { web_vote.update(question.id.to_s => { option_id: option.id.to_s }) }
        end.each(&:join)

        expect(Poll::Voter.count).to be 1
        expect(Poll::Answer.count).to be 1
      end

      it "does not create two voters for duplicate answers" do
        2.times.map do
          Thread.new { web_vote.update(question.id.to_s => { option_id: option_yes.id.to_s }) }
        end.each(&:join)

        expect(Poll::Voter.count).to be 1
      end

      it "validates max votes on multiple-answer questions" do
        question = create(:poll_question_multiple, :abc, poll: poll, max_votes: 2)
        option_a = question.question_options.find_by(title: "Answer A")
        option_b = question.question_options.find_by(title: "Answer B")
        option_c = question.question_options.find_by(title: "Answer C")
        create(:poll_answer, question: question, author: user, option: option_a)

        [option_b, option_c].map do |option|
          Thread.new do
            web_vote.update(question.id.to_s => { option_id: [option_a.id.to_s, option.id.to_s] })
          end
        end.each(&:join)

        expect(Poll::Answer.count).to be 2
      end
    end

    context "Open-ended questions" do
      let!(:open_ended_question) { create(:poll_question_open, poll: poll) }

      it "creates one answer when text is present" do
        web_vote.update(open_ended_question.id.to_s => { answer: "  Hi  " })

        expect(poll.reload.voters.size).to eq 1
        open_answer = open_ended_question.reload.answers.find_by(author: user)

        expect(open_answer.answer).to eq "Hi"
        expect(open_answer.option_id).to be nil
      end

      it "does not create an answer but create voters when text is blank or only spaces" do
        web_vote.update(open_ended_question.id.to_s => { answer: "   " })

        expect(poll.reload.voters.size).to eq 1
        expect(open_ended_question.reload.answers.where(author: user)).to be_empty
      end

      it "deletes existing answer but keeps voters when leaving open-ended blank" do
        create(:poll_answer, question: open_ended_question, author: user, answer: "Old answer")

        web_vote.update(open_ended_question.id.to_s => { answer: "  " })

        expect(poll.reload.voters.size).to eq 1
        expect(open_ended_question.reload.answers.where(author: user)).to be_empty
      end

      it "updates existing open answer without creating duplicates" do
        existing = create(:poll_answer, question: open_ended_question, author: user, answer: "Old text")

        web_vote.update(open_ended_question.id.to_s => { answer: "  New text  " })

        updated = open_ended_question.reload.answers.find_by(author: user)
        expect(updated.id).to eq existing.id
        expect(updated.answer).to eq "New text"
        expect(updated.option_id).to be nil
        expect(poll.reload.voters.size).to eq 1
      end
    end
  end
end
