require "rails_helper"

describe Legislation::QuestionsController do
  describe "GET show" do
    let(:question) { create(:legislation_question) }

    it "has custom order for comments" do
      get :show, params: { process_id: question.process.id, id: question.id }
      expect(controller.valid_orders).to eq %w[most_voted newest oldest]
    end
  end
end
