require "rails_helper"

describe RelatedContentsController do
  describe "#score" do
    it "raises an error if related content does not exist" do
      controller.params[:id] = 0

      expect do
        controller.send(:score, "action")
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
