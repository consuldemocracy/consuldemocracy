require "rails_helper"

describe PollsController do
  describe "GET show" do
    let(:poll) { create(:poll) }

    it "has custom order for comments" do
      get :show, params: { id: poll.id }
      expect(controller.valid_orders).to eq %w[most_voted newest oldest]
    end
  end
end
