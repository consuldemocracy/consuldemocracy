require 'rails_helper'

describe Setting do
  before do
    Setting["official_level_1_name"] = 'Stormtrooper'
  end

  context "when overriden in the database" do
    before do
      Setting["official_level_1_name"] = 'Stormtrooper'
    end

    it "should return the overriden setting" do
      expect(Setting['official_level_1_name']).to eq('Stormtrooper')
    end
  end

  context "when there's a fallback" do
    it "should return the fallback setting" do
      Setting::StaticSetting["crazy_setting"] = "Crazy setting"
      expect(Setting["crazy_setting"]).to eq("Crazy setting")
    end
  end

  context "when there isn't a fallback" do
    it "should should return nil" do
      expect(Setting['undefined_key']).to eq(nil)
    end
  end
end
