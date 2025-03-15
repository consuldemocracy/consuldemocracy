require "rails_helper"

describe Admin::Poll::PollsController, :admin do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.polls"] = false

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  describe "DELETE destroy" do
    it "deletes every question and every option from that poll" do
      poll = create(:poll, name: "Do you support CONSUL?")
      create(:poll_question, :yes_no, poll: poll)

      delete :destroy, params: { id: poll }

      expect(Poll.count).to eq 0
      expect(Poll::Question.count).to eq 0
      expect(Poll::Question::Option.count).to eq 0
    end
  end
end
