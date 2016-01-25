require 'rails_helper'

describe Setting do
  before do
    Setting["official_level_1_name"] = 'Stormtrooper'
  end

  it "should return the overriden setting" do
    expect(Setting['official_level_1_name']).to eq('Stormtrooper')
  end

  it "should should return nil" do
    expect(Setting['undefined_key']).to eq(nil)
  end

  it "should persist a setting on the db" do
    expect(Setting.where(key: 'official_level_1_name', value: 'Stormtrooper')).to exist
  end

  describe "#feature_flag?" do
    it "should be true if key starts with 'feature.'" do
      setting = Setting.create(key: 'feature.whatever')
      expect(setting.feature_flag?).to eq true
    end

    it "should be false if key does not start with 'feature.'" do
      setting = Setting.create(key: 'whatever')
      expect(setting.feature_flag?).to eq false
    end
  end
end
