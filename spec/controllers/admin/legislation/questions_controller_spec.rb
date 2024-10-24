require "rails_helper"

describe Admin::Legislation::QuestionsController, :admin do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.legislation"] = nil

      expect do
        get :index, params: { process_id: create(:legislation_process).id }
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end
end
