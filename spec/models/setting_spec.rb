require 'rails_helper'

describe Setting do

  context "when overriden in the database" do
    before do
      Setting.override("official_level_1_name", 'Stormtrooper')
    end

    it "should return the overriden setting" do
      expect(Setting['official_level_1_name']).to eq('Stormtrooper')
    end

    it "should return the fallback setting when its un-overriden" do
      Setting.delete_override('official_level_1_name')
      expect(Setting['official_level_1_name']).not_to eq('Stormtrooper')
    end
  end

  context "when there's a fallback" do
    it "should return the fallback setting" do
      setting = Setting['official_level_1_name']
      expect(setting).not_to be_blank
      expect(setting).to eq(Setting::StaticSetting.official_level_1_name)
    end
  end

  context "when there's a fallback" do
    it "should should return nil" do
      expect(Setting['undefined_key']).to eq(nil)
    end
  end

  describe "#value_for" do
    it "delegates to []" do
      expect(Setting).to receive(:[]).with(:foo).and_return :bar

      expect(Setting.value_for(:foo)).to eq(:bar)
    end
  end

end
