require "rails_helper"

describe PollsController do
  describe "POST /polls/:id/answer" do
    it "doesn't create duplicate records on simultaneous requests", :race_condition do
      question = create(:poll_question_multiple, :abc)
      option_id = question.option_for("Answer A").id

      sign_in(create(:user, :level_two))
      path = answer_poll_path(question.poll.id)

      2.times.map do
        Thread.new do
          post path, params: { web_vote: { question.id.to_s => { option_id: option_id }}}
        end
      end.each(&:join)

      expect(Poll::Answer.count).to eq 1
    end
  end
end
