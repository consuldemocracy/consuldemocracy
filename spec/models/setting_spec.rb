require "rails_helper"

describe Setting do
  before do
    described_class["official_level_1_name"] = "Stormtrooper"
  end

  it "returns the overriden setting" do
    expect(described_class["official_level_1_name"]).to eq("Stormtrooper")
  end

  it "shoulds return nil" do
    expect(described_class["undefined_key"]).to eq(nil)
  end

  it "persists a setting on the db" do
    expect(described_class.where(key: "official_level_1_name", value: "Stormtrooper")).to exist
  end

  describe "#feature_flag?" do
    it "is true if key starts with 'feature.'" do
      setting = described_class.create(key: "feature.whatever")
      expect(setting.feature_flag?).to eq true
    end

    it "is false if key does not start with 'feature.'" do
      setting = described_class.create(key: "whatever")
      expect(setting.feature_flag?).to eq false
    end
  end

  describe "#enabled?" do
    it "is true if feature_flag and value present" do
      setting = described_class.create(key: "feature.whatever", value: 1)
      expect(setting.enabled?).to eq true

      setting.value = "true"
      expect(setting.enabled?).to eq true

      setting.value = "whatever"
      expect(setting.enabled?).to eq true
    end

    it "is false if feature_flag and value blank" do
      setting = described_class.create(key: "feature.whatever")
      expect(setting.enabled?).to eq false

      setting.value = ""
      expect(setting.enabled?).to eq false
    end

    it "is false if not feature_flag" do
      setting = described_class.create(key: "whatever", value: "whatever")
      expect(setting.enabled?).to eq false
    end
  end

  describe "#banner_style?" do
    it "is true if key starts with 'banner-style.'" do
      setting = described_class.create(key: "banner-style.whatever")
      expect(setting.banner_style?).to eq true
    end

    it "is false if key does not start with 'banner-style.'" do
      setting = described_class.create(key: "whatever")
      expect(setting.banner_style?).to eq false
    end
  end

  describe "#banner_img?" do
    it "is true if key starts with 'banner-img.'" do
      setting = described_class.create(key: "banner-img.whatever")
      expect(setting.banner_img?).to eq true
    end

    it "is false if key does not start with 'banner-img.'" do
      setting = described_class.create(key: "whatever")
      expect(setting.banner_img?).to eq false
    end
  end
end
