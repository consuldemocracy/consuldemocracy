require "rails_helper"

describe Admin::Poll::PollsController, :admin do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.polls"] = false

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  describe "PATCH update" do
    it "renders to edit_admin_poll_path when trying to unpublish a poll with votes" do
      poll = create(:poll, :published)
      create(:poll_question, poll: poll)
      create(:poll_voter, :from_booth, :valid_document, poll: poll)

      poll.published = false

      patch :update, params: {
        id: poll.id,
        poll: poll.attributes
      }

      expect(response).to have_http_status(:success)
    end

    it "redirect to admin_poll_path when unpublish a poll without votes" do
      poll = create(:poll, :published)
      create(:poll_question, poll: poll)

      poll.published = false

      patch :update, params: {
        id: poll.id,
        poll: poll.attributes
      }

      expect(response).to have_http_status(:redirect)
    end
  end
end
