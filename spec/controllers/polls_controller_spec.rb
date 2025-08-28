require "rails_helper"

describe PollsController do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.polls"] = false

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  describe "POST answer" do
    it "doesn't create duplicate records on simultaneous requests", :race_condition do
      question = create(:poll_question_multiple, :abc)
      sign_in(create(:user, :level_two))

      2.times.map do
        Thread.new do
          post :answer, params: {
            id: question.poll.id,
            web_vote: {
              question.id.to_s => { option_id: question.question_options.find_by(title: "Answer A").id }
            }
          }
        rescue AbstractController::DoubleRenderError
        end
      end.each(&:join)

      expect(Poll::Answer.count).to eq 1
    end

    it "denies access when users have already voted in a booth" do
      poll = create(:poll)
      user = create(:user, :level_two)
      create(:poll_voter, :from_booth, poll: poll, user: user)

      sign_in(user)

      post :answer, params: { id: poll.id, web_vote: {}}

      expect(response).to redirect_to "/"
      expect(flash[:alert]).to eq "You do not have permission to access this page."
    end
  end
end
