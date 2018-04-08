require 'rails_helper'

RSpec.describe SettingsHelper, type: :helper do

  describe "#setting" do

    it "returns a hash with all settings values" do
      Setting["key1"] = "value1"
      Setting["key2"] = "value2"

      expect(setting["key1"]).to eq("value1")
      expect(setting["key2"]).to eq("value2")
      expect(setting["key3"]).to eq(nil)
    end
  end

  describe "#feature?" do
    it "returns presence of feature flag setting value" do

      Setting["feature.f1"] = "active"
      Setting["feature.f2"] = ""
      Setting["feature.f3"] = nil

      expect(feature?("f1")).to eq("active")
      expect(feature?("f2")).to eq(nil)
      expect(feature?("f3")).to eq(nil)
      expect(feature?("f4")).to eq(nil)
    end
  end

end