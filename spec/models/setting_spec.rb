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

  describe "#enabled?" do
    it "should be true if feature_flag and value present" do
      setting = Setting.create(key: 'feature.whatever', value: 1)
      expect(setting.enabled?).to eq true

      setting.value = "true"
      expect(setting.enabled?).to eq true

      setting.value = "whatever"
      expect(setting.enabled?).to eq true
    end

    it "should be false if feature_flag and value blank" do
      setting = Setting.create(key: 'feature.whatever')
      expect(setting.enabled?).to eq false

      setting.value = ""
      expect(setting.enabled?).to eq false
    end

    it "should be false if not feature_flag" do
      setting = Setting.create(key: 'whatever', value: "whatever")
      expect(setting.enabled?).to eq false
    end
  end

  describe "#banner_style?" do
    it "should be true if key starts with 'banner-style.'" do
      setting = Setting.create(key: 'banner-style.whatever')
      expect(setting.banner_style?).to eq true
    end

    it "should be false if key does not start with 'banner-style.'" do
      setting = Setting.create(key: 'whatever')
      expect(setting.banner_style?).to eq false
    end
  end

  describe "#banner_img?" do
    it "should be true if key starts with 'banner-img.'" do
      setting = Setting.create(key: 'banner-img.whatever')
      expect(setting.banner_img?).to eq true
    end

    it "should be false if key does not start with 'banner-img.'" do
      setting = Setting.create(key: 'whatever')
      expect(setting.banner_img?).to eq false
    end
  end
end
