require "rails_helper"

describe DebatesController do
  describe "GET show" do
    let(:debate) { create(:debate) }

    it "has custom order for comments" do
      get :show, params: { id: debate.id }
      expect(controller.valid_orders).to eq %w[most_voted newest oldest]
    end
  end
end
