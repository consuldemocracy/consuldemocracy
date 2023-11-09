require "rails_helper"

describe Legislation::AnnotationsController do
  describe "GET show" do
    let(:annotation) { create(:legislation_annotation) }

    it "has custom order for comments" do
      get :show, params: { process_id: annotation.draft_version.process.id,
                           draft_version_id: annotation.draft_version.id,
                           id: annotation.id }
      expect(controller.valid_orders).to eq %w[most_voted newest oldest]
    end
  end
end
