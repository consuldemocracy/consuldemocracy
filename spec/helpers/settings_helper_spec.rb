require "rails_helper"

RSpec.describe SettingsHelper do
  describe "#setting" do
    it "returns a hash with all settings values" do
      Setting["key1"] = "value1"
      Setting["key2"] = "value2"

      expect(setting["key1"]).to eq("value1")
      expect(setting["key2"]).to eq("value2")
      expect(setting["key3"]).to be nil
    end
  end

  describe "#feature?" do
    it "finds settings by the given name prefixed with 'feature.' and returns its presence" do
      Setting["feature.f1"] = "active"
      Setting["feature.f2"] = true
      Setting["feature.f3"] = false
      Setting["feature.f4"] = ""
      Setting["feature.f5"] = nil

      expect(feature?("f1")).to eq("active")
      expect(feature?("f2")).to eq("t")
      expect(feature?("f3")).to be nil
      expect(feature?("f4")).to be nil
      expect(feature?("f5")).to be nil
    end

    it "finds settings by the given name prefixed with 'process.' and returns its presence" do
      Setting["process.p1"] = "active"
      Setting["process.p2"] = true
      Setting["process.p3"] = false
      Setting["process.p4"] = ""
      Setting["process.p5"] = nil

      expect(feature?("p1")).to eq("active")
      expect(feature?("p2")).to eq("t")
      expect(feature?("p3")).to be nil
      expect(feature?("p4")).to be nil
      expect(feature?("p5")).to be nil
    end

    it "finds settings by the full key name and returns its presence" do
      Setting["map.feature.f1"] = "active"
      Setting["map.feature.f2"] = true
      Setting["map.feature.f3"] = false
      Setting["map.feature.f4"] = ""
      Setting["map.feature.f5"] = nil

      expect(feature?("map.feature.f1")).to eq("active")
      expect(feature?("map.feature.f2")).to eq("t")
      expect(feature?("map.feature.f3")).to be nil
      expect(feature?("map.feature.f4")).to be nil
      expect(feature?("map.feature.f5")).to be nil
    end
  end
end
