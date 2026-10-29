require "rails_helper"

describe PollsController do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.polls"] = false

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  describe "POST answer" do
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
