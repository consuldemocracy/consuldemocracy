require "rails_helper"

describe SDGManagement::RelationsController do
  before do
    sign_in create(:administrator).user

    Setting["feature.sdg"] = true
    Setting["sdg.process.budgets"] = true
    Setting["sdg.process.debates"] = true
    Setting["sdg.process.legislation"] = true
    Setting["sdg.process.polls"] = true
    Setting["sdg.process.proposals"] = true
  end

  context "processes disabled" do
    it "raises feature disabled for budgets" do
      Setting["process.budgets"] = false

      expect do
        get :index, params: { relatable_type: "budget/investments" }
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end

    it "raises feature disabled for debates" do
      Setting["process.debates"] = false

      expect do
        get :index, params: { relatable_type: "debates" }
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end

    it "raises feature disabled for legislation processes" do
      Setting["process.legislation"] = false

      expect do
        get :index, params: { relatable_type: "legislation/processes" }
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end

    it "raises feature disabled for polls" do
      Setting["process.polls"] = false

      expect do
        get :index, params: { relatable_type: "polls" }
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end

    it "raises feature disabled for proposals" do
      Setting["process.proposals"] = false

      expect do
        get :index, params: { relatable_type: "proposals" }
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  context "SDG processes disabled" do
    it "raises feature disabled for budgets" do
      Setting["sdg.process.budgets"] = false

      expect do
        get :index, params: { relatable_type: "budget/investments" }
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end

    it "raises feature disabled for debates" do
      Setting["sdg.process.debates"] = false

      expect do
        get :index, params: { relatable_type: "debates" }
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end

    it "raises feature disabled for legislation processes" do
      Setting["sdg.process.legislation"] = false

      expect do
        get :index, params: { relatable_type: "legislation/processes" }
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end

    it "raises feature disabled for polls" do
      Setting["sdg.process.polls"] = false

      expect do
        get :index, params: { relatable_type: "polls" }
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end

    it "raises feature disabled for proposals" do
      Setting["sdg.process.proposals"] = false

      expect do
        get :index, params: { relatable_type: "proposals" }
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end
end
