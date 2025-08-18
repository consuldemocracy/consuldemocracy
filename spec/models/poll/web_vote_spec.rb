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

    it "does not save the answer if the voter is invalid" do
      allow_any_instance_of(Poll::Voter).to receive(:valid?).and_return(false)

      expect do
        web_vote.update(question.id.to_s => { option_id: option_yes.id.to_s })
      end.to raise_error(ActiveRecord::RecordInvalid)

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

    context "essay questions" do
      let!(:essay_question) { create(:poll_question_essay, poll: poll) }

      it "creates one answer when text is present" do
        web_vote.update(essay_question.id.to_s => { text_answer: "  Hi  " })

        expect(poll.reload.voters.size).to eq 1
        essay_answer = essay_question.reload.answers.find_by(author: user)
        expect(essay_answer.text_answer).to eq "Hi"
        expect(essay_answer.option_id).to be nil
      end

      it "does not create an answer but create voters when text is blank or only spaces" do
        web_vote.update(essay_question.id.to_s => { text_answer: "   " })

        expect(poll.reload.voters.size).to eq 1
        expect(essay_question.reload.answers.where(author: user)).to be_empty
      end

      it "deletes existing answer but keeps voters when leaving essay blank" do
        create(:poll_answer, question: essay_question, author: user, text_answer: "Old answer")

        web_vote.update(essay_question.id.to_s => { text_answer: "  " })

        expect(poll.reload.voters.size).to eq 1
        expect(essay_question.reload.answers.where(author: user)).to be_empty
      end
    end

    context "text answer options" do
      before { option_yes.update!(open_text: true) }

      it "stores text for the selected option when provided" do
        web_vote.update(
          question.id.to_s => {
            option_id: option_yes.id.to_s,
            text_answer: { option_yes.id.to_s => "  hello  " }
          }
        )
        answer = question.reload.answers.find_by(author: user, option: option_yes)
        expect(answer).to be_present
        expect(answer.text_answer).to eq "hello"
      end

      it "ignores text for non selected options" do
        option_no.update(open_text: true)
        web_vote.update(
          question.id.to_s => {
            option_id: option_yes.id.to_s,
            text_answer: { option_no.id.to_s => "should be ignored" }
          }
        )
        answer = question.reload.answers.find_by(author: user, option: option_yes)
        expect(answer.text_answer).to eq ""
      end
    end
  end
end
